//
//  TNBSearchCollectionViewCell.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBSearchCollectionViewCell.h"
#import "TNBImageManager.h"
#import "UIImageView+WebCache.h"

@implementation UIColor (Placeholder)
+ (UIColor *)randomColor {
	CGFloat red = arc4random() % 255 / 255.0;
	CGFloat green = arc4random() % 255 / 255.0;
	CGFloat blue = arc4random() % 255 / 255.0;
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	return color;
}

@end

@interface TNBSearchCollectionViewCell() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILongPressGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) NSDate *gestureStarted;

@property (nonatomic, assign) CGPoint gestureInitialLocation;
@end

@implementation TNBSearchCollectionViewCell


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor randomColor];

		[self addSubview:self.backgroundImageView];
		[self addSubview:self.containerView];
		[self.containerView addSubview: self.titleLabel];

		self.gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
		self.gestureRecognizer.minimumPressDuration = 0.0f;
		self.gestureRecognizer.delegate = self;
		[self addGestureRecognizer:self.gestureRecognizer];

	}

	return self;
}

- (void)setImageResourceName: (NSString *)resourceName
					andTitle: (NSString *)title {

	NSString *coverURLString = [[TNBImageManager sharedInstance] urlStringForResource:resourceName type:EImageTypePoster width:self.bounds.size.width];
	NSURL *coverUrl = [NSURL URLWithString:coverURLString];
	if (coverUrl) {
		[self.backgroundImageView sd_setImageWithURL:coverUrl];
	}
	[self setNeedsLayout];
}


- (void)prepareForReuse {
	self.backgroundColor = [UIColor randomColor];
	self.backgroundImageView.image = nil;
	self.titleLabel.attributedText = nil;
	[self.backgroundImageView sd_cancelCurrentImageLoad];
}

- (void)layoutSubviews {
	[super layoutSubviews];



}

#pragma mark - lazy getters

- (UIImageView *)backgroundImageView {
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	return _backgroundImageView;
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.backgroundColor = [UIColor clearColor];
	}
	return _titleLabel;
}

- (UIView *)containerView {
	if (!_containerView) {
		_containerView = [[UIView alloc] initWithFrame:self.bounds];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_containerView.backgroundColor = [UIColor clearColor];
	}
	return _containerView;
}

#pragma mark - Gesture handling
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)longPressEvent:(UILongPressGestureRecognizer *)gesture {

	if(UIGestureRecognizerStateBegan == gesture.state) {
		self.gestureStarted = [NSDate date];
		self.gestureInitialLocation = [gesture locationInView:[UIApplication sharedApplication].keyWindow];

		[self highlighted:YES];
	}

	if (UIGestureRecognizerStateChanged == gesture.state) {
		CGPoint newTouchPoint = [gesture locationInView:[UIApplication sharedApplication].keyWindow];

		CGFloat dx = newTouchPoint.x - self.gestureInitialLocation.x;
		CGFloat dy = newTouchPoint.y - self.gestureInitialLocation.y;
		if (dx*dx + dy*dy > 400.0f) {

			[self highlighted:NO];

			gesture.enabled = NO;
			gesture.enabled = YES;
		}
	}

	if(UIGestureRecognizerStateEnded == gesture.state) {
		[self highlighted:NO];
		if ([self.gestureStarted timeIntervalSinceNow] < - 0.5f && self.secondaryActionCallback) {
			self.secondaryActionCallback();
		} else {
			if (self.defaultActionCallback) {
				self.defaultActionCallback();
			}
		}
	}

	return YES;

}


- (void)highlighted:(BOOL) highlighted {
    [UIView animateWithDuration:0.4f
						  delay:0.0f
		 usingSpringWithDamping:.5f
		  initialSpringVelocity:0.0f
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 CGFloat scale = highlighted ? 0.98f : 1.0f;
						 CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
						 self.layer.transform = CATransform3DMakeAffineTransform(transform);
					 }
					 completion:nil];
}



@end
