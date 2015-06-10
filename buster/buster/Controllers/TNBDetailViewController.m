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

#import "TNBExtendedMovieItem.h"

#import "TNBNetworkManager.h"
#import "UIImage+Alpha.h"

@interface TNBDetailViewController() <iCarouselDataSource, iCarouselDelegate, TNBSearchDetailCellDelegate>

@property (nonatomic, strong) TNBSearchModel *searchModel;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) iCarousel *carouselView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation TNBDetailViewController

- (instancetype)initWithViewModel: (TNBSearchModel *)model
					 initialIndex: (NSUInteger)index {
	self = [self initWithNibName:nil bundle:nil];
	if (self) {
		self.searchModel = model;
		self.currentIndex = index;
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.view addSubview:self.backgroundImageView];
	[self.view addSubview:self.carouselView];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.searchModel addObserver: self
					   forKeyPath: @"currentState"
						  options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
						  context: nil];

	[self.carouselView scrollToItemAtIndex:self.currentIndex animated:NO];


	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
}


// right now it is the simpliest way to handle the custom push animation
// if there would be another VC to push on the stack
// the UINavigationControllerDelegate should be implemented
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[UIView animateWithDuration:1.0f animations:^{
		CGRect frame = CGRectOffset(self.carouselView.frame, 0.0f, - self.carouselView.frame.size.height);
		self.carouselView.frame = frame;

		self.backgroundImageView.alpha = 0.2f;
	} completion:^(BOOL finished) {
		for (id obj in self.carouselView.visibleItemViews) {
			TNBSearchDetailCell *cell = DYNAMIC_CAST(obj, TNBSearchDetailCell);
			[cell recalculateTransformLimits];
		}
	}];
}

- (void)dealloc {
	[self.searchModel removeObserver:self forKeyPath:@"currentState"];
}

#pragma mark - lazy getters

- (UIImageView *)backgroundImageView {
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
		_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_backgroundImageView.image = self.previousScreenShot;
	}
	return _backgroundImageView;
}

- (iCarousel *)carouselView {
	if (!_carouselView) {
		CGRect frame = CGRectOffset(self.view.bounds, 0.0f, self.view.bounds.size.height + 64.0f + 20.0f);
		_carouselView = [[iCarousel alloc] initWithFrame:frame];
		_carouselView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		_carouselView.dataSource = self;
		_carouselView.delegate = self;

		_carouselView.type = iCarouselTypeLinear;
		_carouselView.centerItemWhenSelected = YES;

		_carouselView.backgroundColor = [UIColor clearColor];

	}


	return _carouselView;
}

- (UIButton *)backButton {
	if (!_backButton) {
		_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_backButton.frame = CGRectMake(0, 0, 44.0f, 44.0f);
		UIImage *backMask = [[UIImage imageNamed:@"icon_navbarBack"] imageWithTintColor:[UIColor blackColor]];
		[_backButton setImage: [backMask imageWithTintColor:[ UIColor blackColor]]
					 forState: UIControlStateNormal];

		[_backButton setImage: [backMask imageWithTintColor:[ UIColor darkGrayColor]]
					 forState: UIControlStateHighlighted | UIControlStateSelected];


		[_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}

	return _backButton;
}

- (void)backButtonPressed {
	__block TNBDetailViewController *blockSelf = self;
	[UIView animateWithDuration:1.0f animations:^{
		CGRect frame = CGRectOffset(self.carouselView.frame, 0.0f, self.carouselView.frame.size.height);
		self.carouselView.frame = frame;

		self.backgroundImageView.alpha = 1.0f;
	}
	 completion:^(BOOL finished) {
		 [blockSelf.navigationController popViewControllerAnimated:NO];
	 }];

}

#pragma mark - custom setters
- (void)setPreviousScreenShot:(UIImage *)previousScreenShot {
	if (_previousScreenShot != previousScreenShot) {
		_previousScreenShot = previousScreenShot;
		//shouldn't call the ivar's lazy loader, because it will trigger a view load
		_backgroundImageView.image = previousScreenShot;
	}
}

#pragma mark - iCarouselDataSource
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
	return self.searchModel.movies.count + (self.searchModel.currentState != EModelStateHasAllContent ? 1 : 0);
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
	if (!view) {
		CGFloat edge = IS_DEVICE_IPAD ? 100.0f : 50.0f;
		CGRect frame = UIEdgeInsetsInsetRect(self.carouselView.bounds, UIEdgeInsetsMake(0.0f, edge, 0.0f, edge));
		view = [[TNBSearchDetailCell alloc] initWithFrame:frame];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		TNBSearchDetailCell *myCell = DYNAMIC_CAST(view, TNBSearchDetailCell);
		myCell.delegate = self;
	}

	__block TNBSearchDetailCell *myCell = DYNAMIC_CAST(view, TNBSearchDetailCell);

	if (index < self.searchModel.movies.count) {
		TNBBaseMovieItem *movieItem = DYNAMIC_CAST(self.searchModel.movies[index], TNBBaseMovieItem);
		if (movieItem) {
			[myCell setMovieItem:movieItem];

			if (![movieItem isKindOfClass:[TNBExtendedMovieItem class]]) {
				NSUInteger movieID = movieItem.movieId.unsignedIntegerValue;
				[[TNBNetworkManager sharedInstance] getMovieDetails:movieID complete:^(TNBNetworkRequest *operation, id responseObject) {
					NSDictionary *dict = DYNAMIC_CAST(responseObject, NSDictionary);
					TNBExtendedMovieItem *extendedItem = [[TNBExtendedMovieItem alloc] initWithDictionary:dict];

					if (extendedItem) {
						[self.searchModel.movies replaceObjectAtIndex:index withObject:extendedItem];
						[myCell setMovieItem:extendedItem];
					}
				} fail:^(TNBNetworkRequest *operation, NSError *error) {

				}];
			} else {
			}
		}
	} else {
		if (self.searchModel.currentState == EModelStateHasContent) {
			[self.searchModel loadNextPage];
		}
	}

	return view;
}

#pragma mark - iCarouselDelegate


- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	switch (option) {
		case iCarouselOptionSpacing:
			return IS_DEVICE_IPAD ? 1.05f : 1.1f;
		default:
			return value;
	}
}

#pragma mark - TNBSearchDetailCellDelegate

- (void)cell: (TNBSearchDetailCell *) cell becameFullScreen:(BOOL)fullscreen {
	self.carouselView.scrollEnabled = !fullscreen;

	[self.navigationController setNavigationBarHidden:fullscreen animated:NO];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqualToString:@"currentState"]) {

		if (self.searchModel.currentState == EModelStateHasContent ||
			self.searchModel.currentState == EModelStateHasAllContent) {
			[self.carouselView reloadData];
		}
	}
}

@end
