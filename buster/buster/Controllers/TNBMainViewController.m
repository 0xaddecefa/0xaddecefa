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

	[self.searchModel addObserver:self forKeyPath:@"currentState" options:NSKeyValueObservingOptionNew context:nil];

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
		_containerView.backgroundColor = [UIColor redColor];
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
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_collectionView registerClass:[TNBSearchCollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];

		_collectionView.dataSource = self;
		_collectionView.delegate = self;
	}

	return _collectionView;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self.searchModel setQuery:searchBar.text];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.searchModel.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER	forIndexPath:indexPath];

	return cell;
}



#pragma mark - UICollectionViewDelegate

#pragma mark - FMMosaicLayoutDelegate
- (FMMosaicCellSize)collectionView:(UICollectionView *)collectionView layout:(FMMosaicLayout *)collectionViewLayout mosaicCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0 && indexPath.section == 0) || rand() % 20 < 1;
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
@end
