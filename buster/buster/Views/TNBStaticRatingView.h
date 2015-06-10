//
//  TNBStaticRatingView.h
//
//  Created by Tamas Nemeth on 18/11/14.
//  Copyright (c) 2014 Mofibo. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kStaticRatingMax = 10.0f;

@interface TNBStaticRatingView : UIView
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, assign) CGFloat rateValue;
@property (nonatomic, assign) NSTextAlignment alignment;
@end
