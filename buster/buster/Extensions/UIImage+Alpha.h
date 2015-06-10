// UIImage+Alpha.h
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Helper methods for adding an alpha layer to an image

#import <UIKit/UIKit.h>

@interface UIImage (Alpha)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithColor: (UIColor *)color andSize:(CGSize)size;

@end
