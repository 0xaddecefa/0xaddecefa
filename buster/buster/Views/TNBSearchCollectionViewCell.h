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

@property (nonatomic, copy) ActionCallback defaultActionCallback;
@property (nonatomic, copy) ActionCallback secondaryActionCallback;

- (id)initWithFrame:(CGRect)frame;
- (void)setImageResourceName: (NSString *)resourceName
					andTitle: (NSString *)title;

- (void)showContent;

@end
