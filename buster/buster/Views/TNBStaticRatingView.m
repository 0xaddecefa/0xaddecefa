//
//  TNBStaticRatingView.m
//
//  Created by Tamas Nemeth on 18/11/14.
//  Copyright (c) 2014 Mofibo. All rights reserved.
//

#import "TNBStaticRatingView.h"
#import "UIImage+Alpha.h"

#define RATE_PADDING (IS_DEVICE_IPAD ? 11.0f : 7.0f)

@interface TNBStaticRatingView()

@property (nonatomic, retain) UIImage *emptyRateView;
@property (nonatomic, retain) UIImage *fullRateView;

@end

@implementation TNBStaticRatingView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.maskImage = [UIImage imageNamed:@"icon_rating"];
        self.maximumTrackTintColor = [UIColor darkGrayColor];
        self.minimumTrackTintColor = [UIColor redColor];

        assert(floorf(self.fullRateView.size.width) == floorf(self.emptyRateView.size.width));
    }

    return self;
}

- (void)setMaskImage:(UIImage *)maskImage {
    _maskImage = [maskImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self updateResources];
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    [self updateResources];
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    [self updateResources];
}

- (void)updateResources {

    if (self.minimumTrackTintColor) {
        self.fullRateView = [self.maskImage imageWithTintColor:self.minimumTrackTintColor];
    }
    if (self.maximumTrackTintColor) {
        self.emptyRateView = [self.maskImage imageWithTintColor:self.maximumTrackTintColor];
    }
    if (self.fullRateView && self.emptyRateView) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGFloat scale = self.frame.size.height/self.emptyRateView.size.height;
    CGFloat itemWidth = ceilf(scale * self.emptyRateView.size.width);
    CGFloat paddingWidth = ceilf(scale * RATE_PADDING);

    CGFloat totalWidth = kStaticRatingMax * itemWidth + (kStaticRatingMax -1) * paddingWidth;
    CGFloat initialOffset = 0.0f;

    if (self.alignment == NSTextAlignmentCenter) {
        initialOffset = ceilf((self.frame.size.width - totalWidth) / 2.0f);
    } else if (self.alignment == NSTextAlignmentRight) {
        initialOffset = self.frame.size.width - totalWidth;
    }

    CGRect frame = CGRectMake(initialOffset,0,itemWidth, self.frame.size.height);
    CGFloat rateWholeValue = floorf(self.rateValue);

    for(int i = 0; i < kStaticRatingMax; i++) {
        if (i< rateWholeValue) {
            [self.fullRateView drawInRect:frame];
        } else {
            [self.emptyRateView drawInRect:frame];
        }
        frame.origin.x += itemWidth + paddingWidth;
    }

    frame.origin.x = initialOffset + rateWholeValue * (itemWidth + paddingWidth);

    if (self.rateValue - rateWholeValue > 0.01) {
        UIRectClip(CGRectMake(frame.origin.x, 0, itemWidth * (self.rateValue - rateWholeValue), self.frame.size.height));
        [self.fullRateView drawInRect:frame];
    }

}

- (CGFloat)fillWidth {
    return MIN(self.bounds.size.width, self.bounds.size.width * (self.rateValue / 5.0f));
}

- (void)setRateValue:(CGFloat)rateValue {
    _rateValue = rateValue;
    [self setNeedsDisplay];
}

@end
