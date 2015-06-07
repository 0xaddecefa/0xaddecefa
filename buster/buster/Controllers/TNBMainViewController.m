//
//  TNBMainViewController.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBMainViewController.h"

@interface TNBMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation TNBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.containerView];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
