//
//  TNBImageManager.h
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EImageType) {
	EImageTypePoster,
	EImageTypeBackdrop
};

@interface TNBImageManager : NSObject

+ (instancetype)sharedInstance;

- (NSString *)urlStringForResource: (NSString *)resourceName
							  type: (EImageType)resourceType
							 width: (CGFloat)width;

- (void)clearMemoryCache;

@end
