//
//  MOTextAttachment.m
//  Mofibo
//
//  Created by Tamas Nemeth on 21/01/15.
//  Copyright (c) 2015 Mofibo. All rights reserved.
//

#import "TNBTextAttachment.h"

@implementation TNBTextAttachment

- (id)init {
    self = [super init];
    if (self) {
        self.scale = 1.0f;
    }
    return self;
}
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect bounds;
    bounds.origin = self.origin;
    bounds.size = CGSizeApplyAffineTransform(self.image.size, CGAffineTransformMakeScale(self.scale, self.scale));
    return bounds;
}

@end
