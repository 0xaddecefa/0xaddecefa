//
//  TNBSearchCollectionViewCell.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBSearchCollectionViewCell.h"

@implementation UIColor (Mofibo)
+ (UIColor *)randomColor {
	CGFloat red = arc4random() % 255 / 255.0;
	CGFloat green = arc4random() % 255 / 255.0;
	CGFloat blue = arc4random() % 255 / 255.0;
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	return color;
}

@end

@implementation TNBSearchCollectionViewCell
- (instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	self.backgroundColor = [UIColor randomColor];
	return self;
}

- (void)prepareForReuse {
	self.backgroundColor = [UIColor randomColor];
}

@end
