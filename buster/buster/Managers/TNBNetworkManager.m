//
//  TNBNetworkManager.m
//  buster
//
//  Created by Tamas Nemeth on 06/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBNetworkManager.h"

@interface TNBNetworkManager()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, strong) NSThread *workerThread;


// incomingBuffer is manipulated from any thread, keep it thread safe
@property (atomic, strong) NSMutableArray *incomingBuffer;

// A circular buffer is kept to monitor request dates, so manager plays nice
// and doesn't exceeds the 30 req / 10 sec limit.
// Assuming the NSNetworking layer doesn't cause any jitter, this should catch
// most of the overuse.
@property (nonatomic, strong) NSMutableArray *requestDateBuffer;
@property (nonatomic, assign) NSUInteger currentRequestDateIndex;

@end

@implementation TNBNetworkManager

+ (instancetype)sharedInstance {
	static TNBNetworkManager *sharedInsance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInsance = [[self alloc] init];
	});
	return sharedInsance;
}

- (instancetype)init {

	self = [super initWithBaseURL: [NSURL URLWithString: BASE_URL]];

	if (self) {
		NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
															   diskCapacity:100 * 1024 * 1024
																   diskPath:nil];
		[NSURLCache setSharedURLCache:sharedCache];

		self.incomingBuffer = [NSMutableArray array];
		self.requestDateBuffer = [NSMutableArray array];
		self.workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(workerLoop) object:nil];
		self.workerThread.name = @"Network Manager thread";
		[self.workerThread start];
	}

	return self;
}


- (void)workerLoop {

	self.running = YES;

	self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	while (self.running) {
		@autoreleasepool {

			if (self.incomingBuffer.count > 0) {
				NSDate *timeFrame = [self dateOfRequestWindow];
				if (!timeFrame || [timeFrame timeIntervalSinceNow] < -REQUEST_TIMEFRAME) {
					TNBNetworkRequest *request = DYNAMIC_CAST(self.incomingBuffer.firstObject, TNBNetworkRequest);
					[self.incomingBuffer removeObjectAtIndex:0];
					if (request) {
						[self fireRequest:request];
					}
					continue;
				}
			}

			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:0.5]];
		}
	}
}

- (void)fireRequest: (TNBNetworkRequest *)request {
	assert(self.currentRequestDateIndex < REQUEST_LIMIT);

	NSDate *currentDate = [NSDate date];

	if (self.requestDateBuffer.count < REQUEST_LIMIT) {
		[self.requestDateBuffer addObject:currentDate];
	} else {
		self.requestDateBuffer[self.currentRequestDateIndex] = currentDate;
	}
	self.currentRequestDateIndex = ( self.currentRequestDateIndex + 1 ) % REQUEST_LIMIT;

	[self GET:request.URLString parameters:request.parameters success:^(NSURLSessionDataTask *operation, id responseObject) {
		if (request.complete) {
			if (request.callbackThread) {
				[self performBlock:^{
					request.complete(request, responseObject);
				} onThread:request.callbackThread];
			} else {
				[self performBlockOnMainThread:^{
					request.complete(request, responseObject);
				}];
			}
		}
	} failure:^(NSURLSessionDataTask *operation, NSError *error) {
		if (request.fail) {
			if (request.callbackThread) {
				[self performBlock:^{
					request.fail(request, error);
				} onThread:request.callbackThread];
			} else {
				[self performBlockOnMainThread:^{
					request.fail(request, error);
				}];
			}
		}

	}];

}

- (NSDate *)dateOfRequestWindow {
	assert(self.currentRequestDateIndex < REQUEST_LIMIT);

	if (self.requestDateBuffer.count < REQUEST_LIMIT) {
		return nil;
	}

	return DYNAMIC_CAST(self.requestDateBuffer[self.currentRequestDateIndex], NSDate);
}

- (TNBNetworkRequest *)getConfigurationWithCompletion: (CompletionBlock)complete {
	NSString *urlString = @"configuration";
	NSDictionary *parameters =  @{
								  @"api_key" : API_KEY,
								  };

	TNBNetworkRequest *request = [[TNBNetworkRequest alloc] initWithURLString: urlString
																   parameters: parameters
																	  success: complete
																	  failure: nil];

	if (request) {
		[self.incomingBuffer addObject:request];
	}
	return request;

}


- (TNBNetworkRequest *)search: (NSString *)query
						 page: (NSUInteger)page
					 complete: (CompletionBlock)complete
						 fail: (FailureBlock)fail {
	NSString *urlString = @"search/movie";
	NSString *encodedQuery = [query stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSDictionary *parameters =  @{
								  @"api_key" : API_KEY,
								  @"page" : @(page),
								  @"query" : encodedQuery,
								  @"search_type" : @"ngram",
								  };

	TNBNetworkRequest *request = [[TNBNetworkRequest alloc] initWithURLString: urlString
																   parameters: parameters
																	  success: complete
																	  failure: fail];
	if (request) {
		[self.incomingBuffer addObject:request];
	}

	return request;
}

- (TNBNetworkRequest *)getMovieDetails: (NSUInteger)movieID
							  complete: (CompletionBlock)complete
								  fail: (FailureBlock)fail {

	NSString *urlString = [NSString stringWithFormat:@"movie/%@",@(movieID)];
	NSDictionary *parameters =  @{
								  @"api_key" : API_KEY,
								  };

	TNBNetworkRequest *request = [[TNBNetworkRequest alloc] initWithURLString: urlString
																   parameters: parameters
																	  success: complete
																	  failure: fail];
	if (request) {
		[self.incomingBuffer addObject:request];
	}

	return request;
}


@end
