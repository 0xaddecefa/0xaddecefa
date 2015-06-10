//
//  TNBSearchCollectionViewCell.h
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionCallback)(void);

@interface TNBSearchCollectionViewCell : UICollectionViewCell

//for short tap, and as a fallback if no secondary action is defined
@property (nonatomic, copy) ActionCallback defaultActionCallback;

//could be used for secondary action (fx flipping the Cell, and show some interesting data in the backside)
@property (nonatomic, copy) ActionCallback secondaryActionCallback;

- (id)initWithFrame:(CGRect)frame;
- (void)setImageResourceName: (NSString *)resourceName
					andTitle: (NSString *)title;

- (void)showContent;
- (void)hideContent: (BOOL)animated;
@end
