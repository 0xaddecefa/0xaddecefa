//
//  TNBImageConfigurationModel.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBImageConfigurationModel.h"

@interface TNBImageConfigurationModel()

@property (nonatomic, strong, readwrite) NSString *baseURL;
@property (nonatomic, strong, readwrite) NSDictionary *posterSizes;
@property (nonatomic, strong, readwrite) NSDictionary *backdropSizes;


@end

@implementation TNBImageConfigurationModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];
	if (self) {
		dictionary = DYNAMIC_CAST(dictionary[@"images"], NSDictionary);

		self.baseURL = DYNAMIC_CAST(dictionary[@"base_url"], NSString);
		self.posterSizes = [TNBImageConfigurationModel sizeDictionaryFromList: DYNAMIC_CAST(dictionary[@"poster_sizes"], NSArray)];
		self.backdropSizes = [TNBImageConfigurationModel sizeDictionaryFromList: DYNAMIC_CAST(dictionary[@"backdrop_sizes"], NSArray)];

		if (!self.baseURL || !self.posterSizes || !self.backdropSizes) {
			return nil;
		}
	}

	return self;
}

+ (NSDictionary *)sizeDictionaryFromList: (NSArray *)resourceList {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setPositivePrefix:@"w"];
	for (id obj in resourceList) {
		NSString *item = DYNAMIC_CAST(obj, NSString);
		if (item) {
			NSNumber *number = [numberFormatter numberFromString:item];
			if (number) {
				[dict setObject:item forKey:number];
			} else {
				[dict setObject:item forKey:@(NSUIntegerMax)];
			}
		}
	}

	return [dict copy];
}

@end
