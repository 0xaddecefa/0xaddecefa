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
#import "TNBTextAttachment.h"

#import "TNBDetailViewController.h"

#define REUSE_IDENTIFIER (@"TNBSearchCollectionViewCellIdentifier")

@interface TNBMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, FMMosaicLayoutDelegate>
@property (nonatomic, strong) TNBSearchModel *searchModel;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDate *searchBarLastSearch;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *stateViewContainerView;
@property (nonatomic, strong) UIView *initialView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, assign) BOOL searchBarBecameFirstResponder;

@end

@implementation TNBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.searchModel = [[TNBSearchModel alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardFrameChanged:)
												 name: UIKeyboardWillChangeFrameNotification
											   object: nil];

	[self.view addSubview:self.containerView];
	[self.containerView addSubview:self.collectionView];

	[self.containerView insertSubview:self.stateViewContainerView aboveSubview:self.collectionView];

	self.navigationItem.titleView = self.searchBar;

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!self.searchBarBecameFirstResponder) {
		[self.searchBar becomeFirstResponder];
		self.searchBarBecameFirstResponder = YES;
	}
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

- (UIView *)stateViewContainerView {
	if (!_stateViewContainerView) {
		_stateViewContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
		_stateViewContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_stateViewContainerView.hidden = YES;
	}
	return _stateViewContainerView;
}

- (UIView *)loadingView {
	if (!_loadingView) {
		CGFloat scale = IS_DEVICE_IPAD ? 5.0f : 2.5f;

		_loadingView = [[UIView alloc] initWithFrame:self.stateViewContainerView.bounds];
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.color = [UIColor magentaColor];
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
		activityIndicator.transform = CGAffineTransformMakeScale(scale, scale);
		[activityIndicator startAnimating];
		[_loadingView addSubview:activityIndicator];
		activityIndicator.center = _loadingView.center;
	}
	return _loadingView;
}



- (UIView *)errorView {
	if (!_errorView) {
		_errorView = [[UIView alloc] initWithFrame:self.stateViewContainerView.bounds];
		_errorView.backgroundColor = [UIColor redColor];
		_errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		UILabel *label = [[UILabel alloc] initWithFrame:_errorView.bounds];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = NSTextAlignmentCenter;
		label.numberOfLines = 0;

		label.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"error_message", @"Error happened")
															   attributes: @{
																			 NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline],
																			 NSForegroundColorAttributeName : [UIColor whiteColor],
																			 }];
		[_errorView addSubview:label];
	}
	return _errorView;
}

- (UIView *)emptyView {
	if (!_emptyView) {
		_emptyView = [[UIView alloc] initWithFrame:self.stateViewContainerView.bounds];
		_emptyView.backgroundColor = [UIColor redColor];
		_emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		UILabel *label = [[UILabel alloc] initWithFrame:_emptyView.bounds];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = NSTextAlignmentCenter;
		label.numberOfLines = 0;

		label.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"empty_message", @"No results found")
															   attributes: @{
																			 NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline],
																			 NSForegroundColorAttributeName : [UIColor whiteColor],}];
		[_emptyView addSubview:label];

	}
	return _emptyView;
}

- (UIView *)initialView {
	if (!_initialView) {
		_initialView = [[UIView alloc] initWithFrame:self.stateViewContainerView.bounds];
		_initialView.backgroundColor = [UIColor whiteColor];
		_initialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		UILabel *label = [[UILabel alloc] initWithFrame:_initialView.bounds];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = NSTextAlignmentCenter;
		label.numberOfLines = 0;

		NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
		attachment.image = [UIImage imageNamed:@"icon_search"];

		NSMutableAttributedString *decoratedMessage = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
		NSAttributedString *message = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", NSLocalizedString(@"initial_message", @"Call to action msg")]
																	  attributes: @{
																					NSFontAttributeName : [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline],
																					NSForegroundColorAttributeName : [UIColor blackColor],}];
		[decoratedMessage appendAttributedString:message];

		label.attributedText = decoratedMessage;
		[_initialView addSubview:label];
	}
	return _initialView;
}

- (NSDate *)searchBarLastSearch {
	if (!_searchBarLastSearch) {
		_searchBarLastSearch = [NSDate dateWithTimeIntervalSince1970:0.0f];
	}
	return _searchBarLastSearch;
}


#pragma mark - custom setters
- (void)setSearchModel:(TNBSearchModel *)searchModel {
	if (searchModel != _searchModel) {
		[_searchModel removeObserver:self forKeyPath:@"currentState"];
		_searchModel = searchModel;

		[_searchModel addObserver: self
					   forKeyPath: @"currentState"
						  options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
						  context: nil];

	}
}
#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self.searchModel setQuery:searchBar.text];
	[self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (searchText.length > 2) {
		if ([self.searchBarLastSearch timeIntervalSinceNow] < -0.5f ) {
			[self.searchModel setQuery:searchText];
		}
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.searchModel.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER	forIndexPath:indexPath];

	TNBSearchCollectionViewCell *myCell = DYNAMIC_CAST(cell, TNBSearchCollectionViewCell);

	TNBBaseMovieItem *movieItem = nil;
	if (self.searchModel.movies.count > indexPath.row) {
		movieItem = DYNAMIC_CAST(self.searchModel.movies[indexPath.row], TNBBaseMovieItem);
	}

	[myCell setImageResourceName: movieItem.posterPath
						andTitle: movieItem.title];

	__block TNBMainViewController *blockSelf = self;
	myCell.defaultActionCallback = ^() {
		TNBDetailViewController *vc = [[TNBDetailViewController alloc] initWithViewModel:self.searchModel initialIndex:indexPath.row];
		vc.previousScreenShot = [self saveBackgroundImage];

		[blockSelf.navigationController pushViewController:vc animated:NO];
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
	return 2;//IS_DEVICE_IPAD ? IS_DEVICE_ORIENTATION_LANDSCAPE ? 4 : 3 : 2;
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

		[self showState:self.searchModel.currentState];

		if (self.searchModel.currentState == EModelStateHasContent ||
			self.searchModel.currentState == EModelStateHasAllContent ||
			self.searchModel.currentState == EModelStateError ||
			self.searchModel.currentState == EModelStateEmpty ) {
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


#pragma mark - state view handling
- (void)showState:(EModelState)currentState {

	[self.stateViewContainerView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

	UIView *stateView = [self stateViewForState:currentState];
	if (stateView) {
		stateView.frame = self.stateViewContainerView.bounds;
		stateView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[self.stateViewContainerView addSubview:stateView];
		self.stateViewContainerView.hidden = NO;
	} else {
		self.stateViewContainerView.hidden = YES;
	}
}

- (UIView *)stateViewSuperview {
	return self.view;
}

- (UIView *)stateViewForState:(EModelState)state {

	switch (state) {
		case EModelStateInitial:
			return self.initialView;
		case EModelStateLoading:
			return self.loadingView;
		case EModelStateError:
			return self.errorView;
		case EModelStateEmpty:
			return self.emptyView;
		default:
			return nil;
	}
}

#pragma mark transition helper
-(UIImage *) saveBackgroundImage
{

	CGRect screenRect = [UIScreen mainScreen].applicationFrame;
	screenRect.origin.x = 0.0;
	screenRect.origin.y = 0.0;
	//we need to add an extra 20px because of the status bar
	screenRect.size.height +=20.f;

	UIGraphicsBeginImageContextWithOptions( screenRect.size, YES, 0.0f );
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}


@end
