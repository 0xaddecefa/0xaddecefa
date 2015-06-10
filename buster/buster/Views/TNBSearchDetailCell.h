//
//  TNBSearchDetailCell.h
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNBExtendedMovieItem.h"

@class TNBSearchDetailCell;

@protocol TNBSearchDetailCellDelegate

- (void)cell: (TNBSearchDetailCell *) cell becameFullScreen:(BOOL)fullscreen;

@end

@interface TNBSearchDetailCell : UIView

@property (nonatomic, weak) id<TNBSearchDetailCellDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *contentView;

- (void)setMovieItem:(TNBBaseMovieItem *)item;




@end
