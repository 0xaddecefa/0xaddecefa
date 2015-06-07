//
//  TNBSearchModel.h
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EModelState) {
	EModelStateInitial,
	EModelStateLoading,
	EModelStateReloading,
	EModelStateHasContent,
	EModelStateHasAllContent,
	EModelStateEmpty,
	EModelStateError,
	EModelStateOffline,
};

@interface TNBSearchModel : NSObject

- (void)setQuery: (NSString *)query;
- (void)loadNextPage;

@end
