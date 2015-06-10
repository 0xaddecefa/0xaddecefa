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
#import "TNBStaticRatingView.h"
#import "NSAttributedString+Header.h"

typedef NS_ENUM(NSUInteger, EScrollViewState) {
	EScrollViewStateNone = 0,
	EScrollViewStateTop = 1,
	EScrollViewStateLarge = 2,
};

static const CGFloat kMaxRadii = 10.0f;

@interface TNBSearchDetailCell() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, assign) EScrollViewState scrollViewState;

@property (nonatomic, assign) CGFloat transformStage;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat maxOffset;
@property (nonatomic, assign) CGFloat initialOffset;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TNBStaticRatingView *ratingView;
@property (nonatomic, strong) UITextView *overviewTextView;
@property (nonatomic, strong) UILabel *taglineLabel;
@property (nonatomic, strong) UILabel *releaseDateLabel;
@property (nonatomic, strong) UILabel *productionCompaniesLabel;
@property (nonatomic, strong) UILabel *productionCountriesLabel;

@end

@implementation TNBSearchDetailCell

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {

		[self setLayerRadii:kMaxRadii];

		self.transformStage = 50.0f;

		self.scrollViewState = EScrollViewStateTop;
		[self addSubview:self.contentView];

		[self.contentView addSubview:self.backgroundImageView];
		[self.contentView addSubview:self.coverImageView];
		[self.contentView addSubview:self.titleLabel];
		[self.contentView addSubview:self.ratingView];
		[self.contentView addSubview:self.overviewTextView];

		[self.contentView addSubview:self.taglineLabel];
		[self.contentView addSubview:self.releaseDateLabel];
		[self.contentView addSubview:self.productionCompaniesLabel];
		[self.contentView addSubview:self.productionCountriesLabel];
	}

	return self;
}

- (void)setMovieItem:(TNBBaseMovieItem *)item {

	NSString *coverURLString = [[TNBImageManager sharedInstance] urlStringForResource:item.posterPath type:EImageTypePoster width:IS_DEVICE_IPAD ? 180.0f : 120.0f];
	NSURL *coverUrl = [NSURL URLWithString:coverURLString];
	if (coverUrl) {

		__block TNBSearchDetailCell *blockSelf = self;
		[self.coverImageView sd_setImageWithURL: coverUrl
									  completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
										  if (image && !error) {
											  [blockSelf setNeedsLayout];
										  }
									  }];
	} else {
		self.coverImageView.image = nil;
	}

	NSString *backgroundURLString = [[TNBImageManager sharedInstance] urlStringForResource:item.backdropPath type:EImageTypePoster width:self.bounds.size.width];
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
	} else {
		self.backgroundImageView.image = nil;
	}


	if (item.title) {
		self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: item.title.uppercaseString
																		 attributes: @{
																					   NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline],
																					   NSForegroundColorAttributeName : [UIColor blackColor],
																					   NSKernAttributeName : IS_DEVICE_IPAD ? @(4.0f) : @(2.0f),

																					   }];
	} else {
		self.titleLabel.attributedText = nil;
	}

	if (item.overview) {
		self.overviewTextView.attributedText = [self attributedStringWithHeader:NSLocalizedString(@"label_header_overview", nil) andBody:item.overview];
	} else {
		self.overviewTextView.attributedText = nil;
	}

	TNBExtendedMovieItem *extendedItem = DYNAMIC_CAST(item, TNBExtendedMovieItem);
	self.ratingView.rateValue =  extendedItem.voteAverage.floatValue;

	if (extendedItem.tagline.length > 0) {
		self.taglineLabel.attributedText = [self attributedStringWithHeader:NSLocalizedString(@"label_header_tag", nil) andBody:extendedItem.tagline];
	}

	if (extendedItem.releaseDate) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterMediumStyle;
		dateFormatter.timeStyle = NSDateFormatterNoStyle;
		self.releaseDateLabel.attributedText = [self attributedStringWithHeader:NSLocalizedString(@"label_header_release_date", nil)
																		andBody:[dateFormatter stringFromDate:extendedItem.releaseDate]];
	}

	if (extendedItem.productionCountries.count > 0) {
		NSString *productionCountriesStr = [extendedItem.productionCountries componentsJoinedByString:@"\n"];
		if (productionCountriesStr) {
			self.productionCountriesLabel.attributedText = [self attributedStringWithHeader: NSLocalizedString(@"label_header_countries", nil)
																					andBody: productionCountriesStr];
		}
	}

	if (extendedItem.productionCompanies.count > 0) {
		NSString *productionCompaniesStr = [extendedItem.productionCompanies componentsJoinedByString:@"\n"];
		if (productionCompaniesStr) {
			self.productionCountriesLabel.attributedText = [self attributedStringWithHeader: NSLocalizedString(@"label_header_companies", nil)
																					andBody: productionCompaniesStr];
		}
	}

	[self setNeedsLayout];
	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGFloat spacer = 20.0f;

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

	//RATING
	originY = CGRectGetMaxY(frame) + spacer;
	frame = CGRectMake(spacer,originY,self.contentView.bounds.size.width - 2 * spacer, 22.0f);
	self.ratingView.frame = frame;

	//OVERVIEW
	originY = CGRectGetMaxY(frame) + spacer;

	CGFloat width = self.contentView.bounds.size.width - 2 * spacer - self.overviewTextView.textContainerInset.left - self.overviewTextView.textContainerInset.right;
	height = [self.overviewTextView.attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
																  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
																  context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.overviewTextView.frame = frame;

	//TAGLINE
	originY = CGRectGetMaxY(frame) + spacer;
	height = [self.taglineLabel.attributedText boundingRectWithSize: CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
														  options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
														  context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.taglineLabel.frame = frame;

	//RELEASE DATE
	originY = CGRectGetMaxY(frame) + spacer;
	height = [self.releaseDateLabel.attributedText boundingRectWithSize: CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
															options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
															context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.releaseDateLabel.frame = frame;

	//
	originY = CGRectGetMaxY(frame) + spacer;
	height = [self.productionCompaniesLabel.attributedText boundingRectWithSize: CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
																options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
																context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.productionCompaniesLabel.frame = frame;

	originY = CGRectGetMaxY(frame) + spacer;

	originY = CGRectGetMaxY(frame) + spacer;
	height = [self.productionCountriesLabel.attributedText boundingRectWithSize: CGSizeMake(self.contentView.bounds.size.width - 2 * spacer, CGFLOAT_MAX)
																options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
																context: nil].size.height;
	frame = CGRectMake(spacer, originY, self.contentView.bounds.size.width - 2 *spacer, height);
	self.productionCountriesLabel.frame = frame;

	originY = CGRectGetMaxY(frame) + spacer;

	self.contentView.contentSize = CGSizeMake(self.contentView.bounds.size.width, originY * self.transform.a);
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

- (TNBStaticRatingView *)ratingView {
	if (!_ratingView) {
		_ratingView = [[TNBStaticRatingView alloc] initWithFrame:CGRectZero];
		_ratingView.backgroundColor = [UIColor clearColor];
		_ratingView.alignment = NSTextAlignmentCenter;
	}
	return _ratingView;
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

- (UILabel *)taglineLabel {
	if (!_taglineLabel) {
		_taglineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_taglineLabel.numberOfLines = 0;
	}
	return _taglineLabel;
}

- (UILabel *)releaseDateLabel {
	if (!_releaseDateLabel) {
		_releaseDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_releaseDateLabel.textAlignment = NSTextAlignmentCenter;
		_releaseDateLabel.numberOfLines = 0;
	}
	return _releaseDateLabel;
}

- (UILabel *)productionCompaniesLabel {
	if (!_productionCompaniesLabel) {
		_productionCompaniesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_productionCompaniesLabel.textAlignment = NSTextAlignmentCenter;
		_productionCompaniesLabel.numberOfLines = 0;
	}
	return _productionCompaniesLabel;
}

- (UILabel *)productionCountriesLabel {
	if (!_productionCountriesLabel) {
		_productionCountriesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_productionCountriesLabel.textAlignment = NSTextAlignmentCenter;
		_productionCountriesLabel.numberOfLines = 0;
	}
	return _productionCountriesLabel;
}


- (void)setTransform:(CGAffineTransform)transform {
	if (CGAffineTransformIsIdentity(self.transform) && !CGAffineTransformIsIdentity(transform)) {
		[self.delegate cell:self becameFullScreen:YES];
	}
	if  (!CGAffineTransformIsIdentity(self.transform) && CGAffineTransformIsIdentity(transform)) {
		[self.delegate cell:self becameFullScreen:NO];
	}

	[super setTransform:transform];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.initialOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	self.scrollViewState &= ~EScrollViewStateTop;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGFloat radii = kMaxRadii;
	if ((self.layer.transform.m11 - 1.0f) > 0.5 * self.maxScale) {

		self.scrollViewState = EScrollViewStateLarge;
		CGFloat scale = self.maxScale + 1.0f;
		transform = CGAffineTransformTranslate(CGAffineTransformScale(transform, scale, scale), 0, self.maxOffset);
		radii = 0.0f;
	}

	__block TNBSearchDetailCell *blockSelf = self;
	[UIView animateWithDuration:0.25f animations:^{
		self.transform = transform;
		[self setLayerRadii:radii];
	} completion:^(BOOL finished) {
		[blockSelf setNeedsLayout];
	}];


}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if (self.scrollViewState & EScrollViewStateTop) {
		CGFloat contentOffsetY = scrollView.contentOffset.y;
		if (contentOffsetY > 0.0f && !(self.scrollViewState & EScrollViewStateLarge)) {
			CGFloat transformRatio = MAX( 0, MIN( 1, contentOffsetY / self.transformStage));
			CGFloat scale = transformRatio * self.maxScale + 1.0f;
			CGFloat offset = transformRatio * self.maxOffset;
			CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformIdentity, scale, scale), 0.0f, offset);
			self.transform = transform;

			CGFloat radii = (1-transformRatio) * kMaxRadii;
			[self setLayerRadii:radii];
		} else {
			if (contentOffsetY < 0.0f && self.scrollViewState & EScrollViewStateLarge) {
				CGFloat transformRatio = 1 - MAX( 0, MIN( 1, -contentOffsetY / self.transformStage));
				CGFloat scale = transformRatio * self.maxScale + 1.0f;
				CGFloat offset = transformRatio * self.maxOffset;
				CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformIdentity, scale, scale), 0.0f, offset);
				self.transform = transform;

				CGFloat radii = (1-transformRatio) * kMaxRadii;
				[self setLayerRadii:radii];

			}
		}

	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.scrollViewState = (fabs(scrollView.contentOffset.y) < FLT_EPSILON) ? EScrollViewStateTop : EScrollViewStateNone;
	if ((self.layer.transform.m11 - 1.0f) > 0.5 * self.maxScale) {
		self.scrollViewState |= EScrollViewStateLarge;
	}
}

- (void)didMoveToWindow {
	[self recalculateTransformLimits];
}

- (void)recalculateTransformLimits {
	self.maxScale = ([UIScreen mainScreen].bounds.size.width / self.bounds.size.width) - 1.0f;
	CGFloat originalCenter = [self convertPoint:self.center toView:[UIApplication sharedApplication].keyWindow].y;
	CGFloat offset = originalCenter - ([UIScreen mainScreen].bounds.size.height / 2.0f);
	self.maxOffset =  offset;

}

- (void)setLayerRadii: (CGFloat) radii {

	radii = MAX(0.0f,MIN(radii,kMaxRadii));

	UIBezierPath *maskPath;
	maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
									 byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
										   cornerRadii:CGSizeMake(radii, radii)];

	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	self.layer.mask = maskLayer;

}

- (NSAttributedString *)attributedStringWithHeader: (NSString *)header andBody:(NSString *)body {
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.paragraphSpacing = 10.0f;
	paragraphStyle.hyphenationFactor = 1.0f;
	paragraphStyle.lineHeightMultiple = 1.5f;

	NSDictionary *generalStyle = @{
								   NSParagraphStyleAttributeName : paragraphStyle,
								   NSForegroundColorAttributeName : [UIColor darkTextColor]
								   };

	NSDictionary *headerStyle = @{
								  NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline],
								  };

	NSDictionary *bodyStyle = @{
								NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleBody],
								};

	return [NSAttributedString attributedStringWithFormat:@"%@\n%@" values:@[header, body] specifiers:@[generalStyle, headerStyle, bodyStyle]];
}

@end
