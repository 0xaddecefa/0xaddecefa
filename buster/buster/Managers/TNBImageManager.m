//
//  TNBImageManager.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBImageManager.h"
#import "TNBNetworkManager.h"

#import "TNBImageConfigurationModel.h"
#import "SDImageCache.h"

static NSString *kImageConfigurationCache = @"imageConfigurationCache";

@interface TNBImageManager()
@property (nonatomic, strong) TNBImageConfigurationModel *configurationModel;
@end


@implementation TNBImageManager

+ (instancetype)sharedInstance {
	static TNBImageManager *sharedInsance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInsance = [[self alloc] init];
	});
	return sharedInsance;
}

- (instancetype)init {
	self = [super init];
	if (self) {

		NSDictionary *cachedImageConfiguration = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kImageConfigurationCache];
		if (cachedImageConfiguration) {
			self.configurationModel = [[TNBImageConfigurationModel alloc] initWithDictionary:cachedImageConfiguration];
		}

		[SDImageCache sharedImageCache].maxCacheSize = 100*1024*1024;
		[SDImageCache sharedImageCache].maxMemoryCost = 10*1024*1024;

		[self refreshConfiguration];


	}

	return self;
}

- (void)refreshConfiguration {
	__block TNBImageManager *blockSelf = self;
	[[TNBNetworkManager sharedInstance] getConfigurationWithCompletion:^(TNBNetworkRequest *operation, id responseObject) {
		NSDictionary *dictionary = DYNAMIC_CAST(responseObject, NSDictionary);
		if (dictionary) {
			TNBImageConfigurationModel *updatedImageConfigurationModel = [[TNBImageConfigurationModel alloc] initWithDictionary:dictionary];
			if (updatedImageConfigurationModel) {
				[[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:kImageConfigurationCache];
				[[NSUserDefaults standardUserDefaults] synchronize];
				blockSelf.configurationModel = updatedImageConfigurationModel;
			}
		}

	}];
}

- (void)clearMemoryCache {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (NSString *)urlStringForResource: (NSString *)resourceName
							  type: (EImageType)resourceType
							 width: (CGFloat)width {

	if (!resourceName) return nil;

	NSString *urlString = nil;

	width *= [[UIScreen mainScreen] scale];
	__block NSString *properWidth = nil;
	NSDictionary *widthOptions = nil;

	switch (resourceType) {
		case EImageTypePoster:
			widthOptions = self.configurationModel.posterSizes;
			break;
		case EImageTypeBackdrop:
			widthOptions = self.configurationModel.backdropSizes;
			break;
	}
	NSArray *widths = [widthOptions.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSNumber *a = DYNAMIC_CAST(obj1, NSNumber);
		NSNumber *b = DYNAMIC_CAST(obj2, NSNumber);
		return a.unsignedIntegerValue > b.unsignedIntegerValue;
	}];

	[widths enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSNumber *num = DYNAMIC_CAST(obj, NSNumber);
		if (width > [num floatValue]) {
			properWidth = widths[MIN(idx + 1, widths.count - 1)];
			*stop = YES;
		}
	}];
	if (!properWidth) {
		properWidth = [widths firstObject];
	}

	urlString = [NSString stringWithFormat:@"%@%@%@", self.configurationModel.baseURL, widthOptions[properWidth], resourceName];


	return urlString;
}



@end
