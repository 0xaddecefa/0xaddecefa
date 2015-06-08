//
//  TNBDetailMainViewController.m
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBDetailViewController.h"
#import "TNBSearchDetailCell.h"
#import "iCarousel.h"

@interface TNBDetailViewController() <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) TNBSearchModel *searchModel;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, strong) iCarousel *carouselView;
@end

@implementation TNBDetailViewController

- (instancetype)initWithViewModel: (TNBSearchModel *)model
					 initialIndex: (NSUInteger)index {
	self = [self initWithNibName:nil bundle:nil];
	if (self) {
		self.searchModel = model;
		self.currentIndex = index;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:self.carouselView];

	[self.carouselView scrollToItemAtIndex:self.currentIndex animated:NO];
}

#pragma mark - lazy getters

- (iCarousel *)carouselView {
	if (!_carouselView) {
		_carouselView = [[iCarousel alloc] initWithFrame:self.view.bounds];
		_carouselView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		_carouselView.dataSource = self;
		_carouselView.delegate = self;

		_carouselView.type = iCarouselTypeLinear;
		_carouselView.centerItemWhenSelected = YES;

	}


	return _carouselView;
}


#pragma mark - iCarouselDataSource
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
	return self.searchModel.movies.count + (self.searchModel.currentState != EModelStateHasAllContent ? 1 : 0);
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
	if (!view) {
		CGRect frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0.0f, 50.0f, 0.0f, 50.0f));
		view = [[TNBSearchDetailCell alloc] initWithFrame:frame];
	}

	view.backgroundColor = index % 2 ? [UIColor yellowColor] : [UIColor redColor];
	return view;
}

#pragma mark - iCarouselDelegate


- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	switch (option) {
		case iCarouselOptionSpacing:
			return 1.1f;
		default:
			return value;
	}
}
@end
