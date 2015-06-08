//
//  TNBSearchDetailCell.m
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBSearchDetailCell.h"

#import "TNBImageManager.h"
#import "UIImageView+WebCache.h"
#import "FXBlurView.h"

typedef NS_ENUM(NSUInteger, EScrollViewState) {
	EScrollViewStateZero = 0,
	EScrollViewStateTop = 1,
	EScrollViewStateLarge = 2,
};

@interface TNBSearchDetailCell() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, assign) EScrollViewState scrollViewState;
@property (nonatomic, assign) CGFloat maxScale;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *overviewTextView;

@end

@implementation TNBSearchDetailCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		UIBezierPath *maskPath;
		maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
										 byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
											   cornerRadii:CGSizeMake(10.0, 10.0)];

		CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
		maskLayer.frame = self.bounds;
		maskLayer.path = maskPath.CGPath;
		self.layer.mask = maskLayer;

		self.maxScale = ([UIScreen mainScreen].bounds.size.width / self.bounds.size.width) - 1.0f;
		self.scrollViewState = EScrollViewStateTop;
		[self addSubview:self.contentView];

		[self.contentView addSubview:self.backgroundImageView];
		[self.contentView addSubview:self.coverImageView];
		[self.contentView addSubview:self.titleLabel];
		[self.contentView addSubview:self.overviewTextView];
	}

	return self;
}

// this function could be extended so the TNBExtendedMovieItem properties would be used as well
- (void)setPosterResourceName: (NSString *)posterResourceName
	   backgroundResourceName: (NSString *)backgroundResourceName
						title: (NSString *)title
					 overview: (NSString *)overview {
	NSString *coverURLString = [[TNBImageManager sharedInstance] urlStringForResource:posterResourceName type:EImageTypePoster width:IS_DEVICE_IPAD ? 180.0f : 120.0f];
	NSURL *coverUrl = [NSURL URLWithString:coverURLString];
	if (coverUrl) {

		__block TNBSearchDetailCell *blockSelf = self;
		[self.coverImageView sd_setImageWithURL: coverUrl
									  completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
										  if (image && !error) {
											  [blockSelf setNeedsLayout];
										  }
									  }];
	}

	NSString *backgroundURLString = [[TNBImageManager sharedInstance] urlStringForResource:posterResourceName type:EImageTypePoster width:self.bounds.size.width];
	NSURL *backgroundURL = [NSURL URLWithString:backgroundURLString];
	if (backgroundURL) {

		__block TNBSearchDetailCell *blockSelf = self;
		[self.backgroundImageView sd_setImageWithURL: backgroundURL
									  completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
										  if (image && !error) {
											  UIImage *blurredImage = [image blurredImageWithRadius:10.0f
																						 iterations:16 tintColor:[UIColor redColor]];
											  blockSelf.backgroundImageView.image = blurredImage;
											  [blockSelf setNeedsLayout];
										  }
									  }];
	}


	if (title) {
		self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: title.uppercaseString
																		 attributes: @{
																					   NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline],
																					   NSForegroundColorAttributeName : [UIColor blackColor],
																					   NSKernAttributeName : IS_DEVICE_IPAD ? @(4.0f) : @(2.0f),

																					   }];
	} else {
		self.titleLabel.attributedText = nil;
	}


	if (overview) {
		self.overviewTextView.attributedText = [[NSAttributedString alloc] initWithString: overview
																			   attributes: @{
																					   NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleBody],
																					   NSForegroundColorAttributeName : [UIColor darkTextColor],
																					   }];
	} else {
		self.overviewTextView.attributedText = nil;
	}

	[self setNeedsLayout];
	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGFloat spacer = 10.0f;

	CGFloat imageViewWidth = IS_DEVICE_IPAD ? 180.0f : 120.0f;
	CGSize imageSize = self.coverImageView.image.size;
	CGFloat aspectRatio = 1.0f;
	if (imageSize.width > FLT_EPSILON) {
		aspectRatio = imageSize.height / imageSize.width;
	}
	CGFloat imageViewHeight = imageViewWidth * aspectRatio;

	CGRect frame = CGRectMake ((self.contentView.bounds.size.width - imageViewWidth ) / 2.0f,
							   40.0f,
							   imageViewWidth,
							   imageViewHeight);

	self.coverImageView.frame = frame;

	self.backgroundImageView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, CGRectGetMaxY(frame) - 40.0f);

	//TITLE
	CGFloat originY = CGRectGetMaxY(frame) + spacer;
	CGFloat height = [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
														 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
														 context: nil].size.height;

	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.titleLabel.frame = frame;


	//OVERVIEW
	originY = CGRectGetMaxY(frame) + spacer;
	height = [self.overviewTextView.attributedText boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
																  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
																  context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.overviewTextView.frame = frame;


	originY = CGRectGetMaxY(frame) + spacer;
	self.contentView.contentSize = CGSizeMake(self.contentView.bounds.size.width, originY);
}

#pragma mark - lazy getters

- (UIScrollView *)contentView {
	if (!_contentView) {
		_contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_contentView.alwaysBounceVertical = YES;
		_contentView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
		_contentView.delegate = self;
	}
	return _contentView;
}


- (UIImageView *)backgroundImageView {
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	}
	return _backgroundImageView;
}

- (UIImageView *)coverImageView {
	if (!_coverImageView) {
		_coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	}
	return _coverImageView;
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.numberOfLines = 0;
	}
	return _titleLabel;
}

- (UITextView *)overviewTextView {
	if (!_overviewTextView) {
		_overviewTextView = [[UITextView alloc] initWithFrame:CGRectZero];
		_overviewTextView.scrollEnabled = NO;
		_overviewTextView.backgroundColor = [UIColor clearColor];
		_overviewTextView.editable = NO;
		_overviewTextView.textContainer.lineFragmentPadding = 0;
		_overviewTextView.textContainerInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);

	}
	return _overviewTextView;
}


#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	if ((self.layer.transform.m11 - 1.0f) > 0.5 * self.maxScale) {
//
//		self.scrollViewState = EScrollViewStateLarge;
//
//		[UIView animateWithDuration:0.25f animations:^{
//			self.layer.transform = CATransform3DMakeScale(self.maxScale + 1.0f, self.maxScale + 1.0, 1.0f);
//		}];
//	}
//
//}
//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { [self setNeedsLayout];}
//
//	if (self.scrollViewState == EScrollViewStateTop) {
//		CGFloat contentOffsetY = scrollView.contentOffset.y;
//		if (contentOffsetY > 0.0f) {
//			CGFloat scale = MIN(self.maxScale, self.maxScale * contentOffsetY / 100.0f) + 1.0f;
//			CATransform3D transform = CATransform3DMakeScale(scale, scale, 1.0f);
//			self.layer.transform = transform;
//		}
//
//	}
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	self.scrollViewState = (fabs(scrollView.contentOffset.y) < FLT_EPSILON) ? EScrollViewStateTop : EScrollViewStateZero;
////	if (!CATransform3DIsIdentity(self.layer.transform)) {
////		self.scrollViewState |= EScrollViewStateLarge;
////	}
//}
@end
