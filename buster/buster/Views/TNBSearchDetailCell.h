//
//  TNBSearchDetailCell.h
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNBSearchDetailCell : UIView

@property (nonatomic, strong, readonly) UIScrollView *contentView;

- (void)setPosterResourceName: (NSString *)posterResourceName
	   backgroundResourceName: (NSString *)backgroundResourceName
						title: (NSString *)title
					 overview: (NSString *)overView;




@end
