//
//  TNBMainViewController.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBMainViewController.h"
#import "TNBSearchCollectionViewCell.h"
#import "TNBSearchModel.h"
#import "TNBBaseMovieItem.h"


#import "FMMosaicLayout.h"

#define REUSE_IDENTIFIER (@"TNBSearchCollectionViewCellIdentifier")

@interface TNBMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, FMMosaicLayoutDelegate>
@property (nonatomic, strong) TNBSearchModel *searchModel;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation TNBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.searchModel = [[TNBSearchModel alloc] init];

	[self.searchModel addObserver: self
					   forKeyPath: @"currentState"
						  options: NSKeyValueObservingOptionNew
						  context: nil];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardFrameChanged:)
												 name: UIKeyboardWillChangeFrameNotification
											   object: nil];

	[self.view addSubview:self.containerView];
	[self.containerView addSubview:self.collectionView];

	self.navigationItem.titleView = self.searchBar;

}


- (void)dealloc {
	[self.searchModel removeObserver:self forKeyPath:@"currentState"];
}

#pragma mark - lazy getters

- (UIView *)containerView {
	if (!_containerView) {
		_containerView = [[UIView alloc] initWithFrame:self.view.bounds];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_containerView.backgroundColor = [UIColor whiteColor];
	}

	return _containerView;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
		_searchBar.delegate = self;

	}
	return _searchBar;
}

- (UICollectionView *)collectionView {
	if (!_collectionView) {
		FMMosaicLayout *layout = [[FMMosaicLayout alloc] init];
		_collectionView = [[UICollectionView alloc] initWithFrame:self.containerView.bounds collectionViewLayout:layout];
		_collectionView.backgroundColor = [UIColor clearColor];
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_collectionView.alwaysBounceVertical = YES;
		[_collectionView registerClass:[TNBSearchCollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];

		_collectionView.dataSource = self;
		_collectionView.delegate = self;
	}

	return _collectionView;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self.searchModel setQuery:searchBar.text];
	[self.searchBar resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.searchModel.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER	forIndexPath:indexPath];

	TNBSearchCollectionViewCell *myCell = DYNAMIC_CAST(cell, TNBSearchCollectionViewCell);

	TNBBaseMovieItem *movieItem = DYNAMIC_CAST(self.searchModel.movies[indexPath.row], TNBBaseMovieItem);

	[myCell setImageResourceName: movieItem.posterPath
						andTitle: movieItem.title];

	myCell.defaultActionCallback = ^() {

	};

	return cell;
}



#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		CGFloat scrollContentYOffset = self.collectionView.contentOffset.y;
		CGFloat scrollContentHeight = self.collectionView.contentSize.height;
		CGFloat scrollViewHeight = self.collectionView.bounds.size.height;

		CGFloat scrollDistanceFromBottom = scrollContentHeight - scrollViewHeight - scrollContentYOffset;
		if (scrollDistanceFromBottom < 300.f && self.searchModel.currentState == EModelStateHasContent) {
			[self.searchModel loadNextPage];
		}

		for (id obj in self.collectionView.visibleCells) {
			TNBSearchCollectionViewCell *cell = DYNAMIC_CAST(obj, TNBSearchCollectionViewCell);
			[cell showContent];
		}
	}
}


#pragma mark - FMMosaicLayoutDelegate

- (NSInteger)collectionView: (UICollectionView *)collectionView
					 layout: (FMMosaicLayout *)collectionViewLayout
   numberOfColumnsInSection: (NSInteger)section {
	return 2;IS_DEVICE_IPAD ? IS_DEVICE_ORIENTATION_LANDSCAPE ? 4 : 3 : 2;
}


- (FMMosaicCellSize)collectionView: (UICollectionView *)collectionView
							layout: (FMMosaicLayout *)collectionViewLayout
  mosaicCellSizeForItemAtIndexPath: (NSIndexPath *)indexPath {



	return indexPath.row % 3 == 0 ? FMMosaicCellSizeBig : FMMosaicCellSizeSmall;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if ([keyPath isEqualToString:@"currentState"]) {
		if (self.searchModel.currentState == EModelStateHasContent ||
			self.searchModel.currentState == EModelStateHasAllContent) {
			[self.collectionView reloadData];
		}
	}
}


#pragma mark - keyboard 

- (void)keyboardFrameChanged:(NSNotification *) notification {
	NSDictionary *userinfo = notification.userInfo;
	CGRect endFrame;
	[[userinfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
	endFrame = [self.view convertRect:endFrame fromView:nil];
	NSNumber *durationValue = DYNAMIC_CAST(userinfo[UIKeyboardAnimationDurationUserInfoKey], NSNumber);
	CGFloat animationDuration = [durationValue floatValue];

	[UIView animateWithDuration:animationDuration animations:^{
		CGRect frame = self.containerView.frame;
		frame.size.height = endFrame.origin.y;
		self.containerView.frame = frame;
	}];

}


@end
