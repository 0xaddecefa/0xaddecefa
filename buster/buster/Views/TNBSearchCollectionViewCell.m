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
	CGFloat lightness = (128 + arc4random() % 127) / 255.0f;
	UIColor *color = [UIColor colorWithWhite:lightness alpha:1.0f];
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

@property (nonatomic, strong) NSTimer *hideDetailsTimer;
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

- (void)dealloc {
	[self.hideDetailsTimer invalidate];
	self.hideDetailsTimer = nil;
}

- (void)setImageResourceName: (NSString *)resourceName
					andTitle: (NSString *)title {

	NSString *coverURLString = [[TNBImageManager sharedInstance] urlStringForResource:resourceName type:EImageTypePoster width:self.bounds.size.width];
	NSURL *coverUrl = [NSURL URLWithString:coverURLString];
	if (coverUrl) {
		__block TNBSearchCollectionViewCell *blockSelf = self;
		[self.backgroundImageView sd_setImageWithURL: coverUrl
										   completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
											   if (image && !error) {
												   [blockSelf showContent];
											   }
										   }];
	}
	if (title) {
		self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: title
																		 attributes: @{
																					   NSFontAttributeName : [UIFont preferredFontForTextStyle: IS_DEVICE_IPAD ? UIFontTextStyleHeadline : UIFontTextStyleSubheadline],
																					   NSForegroundColorAttributeName : [UIColor whiteColor],


																								   }];
	} else {
		self.titleLabel.attributedText = nil;
	}
	
	[self setNeedsLayout];
}


- (void)prepareForReuse {
	[self.hideDetailsTimer invalidate];
	self.hideDetailsTimer = nil;

	self.backgroundImageView.image = nil;
	self.titleLabel.attributedText = nil;
	[self.backgroundImageView sd_cancelCurrentImageLoad];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect boundingRect = CGRectInset(self.containerView.bounds, 10.0f, 10.0f);
	CGFloat height = [self.titleLabel.attributedText boundingRectWithSize: boundingRect.size
																  options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
																  context: nil].size.height;
	self.titleLabel.frame = CGRectMake(10.0f, self.containerView.bounds.size.height - height - 10.0f, boundingRect.size.width, height);


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
		_titleLabel.numberOfLines = 0;
		_titleLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _titleLabel;
}

- (UIView *)containerView {
	if (!_containerView) {
		_containerView = [[UIView alloc] initWithFrame:self.bounds];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
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
		[self showContent];
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

- (void)showContent {
	[self.hideDetailsTimer invalidate];
	__block TNBSearchCollectionViewCell *blockSelf = self;
	[UIView animateWithDuration:0.5f
					 animations:^{
						 blockSelf.containerView.alpha = 1.0f;
	} completion:^(BOOL finished) {
		blockSelf.hideDetailsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:blockSelf selector:@selector(hideContent) userInfo:nil repeats:NO];
	}];
}

- (void)hideContent {
	[self hideContent:YES];
}

- (void)hideContent:(BOOL)animated {
	__block TNBSearchCollectionViewCell *blockSelf = self;
	[UIView animateWithDuration:animated ? 0.5f : 0.0f
					 animations:^{
						 if (blockSelf.backgroundImageView.image) {
							 blockSelf.containerView.alpha = 0.0f;
							 blockSelf.hideDetailsTimer = nil;
						 }
					 }];
}

@end
