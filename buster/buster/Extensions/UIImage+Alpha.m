// UIImage+Alpha.m
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Alpha.h"

@implementation UIImage (Alpha)

// Returns a copy of the image tinted with tintColor
- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithColor: (UIColor *)color andSize:(CGSize)size {

	if (CGSizeEqualToSize(size, CGSizeZero)) {
		size = CGSizeMake(2.0f, 2.0f);
	}

	UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[color setFill];
	CGContextFillRect(context, rect);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	newImage = [newImage resizableImageWithCapInsets:UIEdgeInsetsZero];

	return newImage;
}
@end
