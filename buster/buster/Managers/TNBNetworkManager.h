//
//  TNBNetworkManager.h
//  buster
//
//  Created by Tamas Nemeth on 06/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import "TNBNetworkRequest.h"

@interface TNBNetworkManager : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (TNBNetworkRequest *)getConfigurationWithCompletion: (CompletionBlock)complete;

- (TNBNetworkRequest *)search: (NSString *)query
					 complete: (CompletionBlock)complete
						 fail: (FailureBlock)fail;

- (TNBNetworkRequest *)getMovieDetails: (NSUInteger)movieID
							  complete: (CompletionBlock)complete
								  fail: (FailureBlock)fail;

@end
