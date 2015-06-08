//
//  TNBDetailMainViewController.h
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TNBSearchModel.h"

@interface TNBDetailViewController : UIViewController

- (instancetype)initWithViewModel: (TNBSearchModel *)model
					 initialIndex: (NSUInteger)index;

@end
