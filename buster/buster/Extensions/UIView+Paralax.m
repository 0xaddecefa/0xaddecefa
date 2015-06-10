//
//  UIView+Paralax.m
//  buster
//
//  Created by Tamas Nemeth on 10/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "UIView+Paralax.h"

static void * const kParallaxDepthKey = (void*)&kParallaxDepthKey;


@implementation UIView (Paralax)

-(void)setParallaxIntensity:(CGFloat)parallaxDepth {
	if (self.parallaxIntensity == parallaxDepth)
		return;

	objc_setAssociatedObject(self, kParallaxDepthKey, @(parallaxDepth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	[self applyParallax];
}

-(CGFloat)parallaxIntensity {
	NSNumber * val = objc_getAssociatedObject(self, kParallaxDepthKey);

	if (!val) {
		return 0.0;
	}

	return val.doubleValue;
}


- (void)applyParallax {
	CGFloat parallaxDepth = self.parallaxIntensity;

	for (id obj in self.motionEffects) {
		UIMotionEffect *motionEffect = DYNAMIC_CAST(obj, UIMotionEffect);
		if (motionEffect) {
			[self removeMotionEffect:motionEffect];
		}
	}

	if (parallaxDepth == 0.0) {
		return;
	}

	UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y"
																										type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalMotionEffect.minimumRelativeValue = @(-self.parallaxIntensity);
	verticalMotionEffect.maximumRelativeValue = @(self.parallaxIntensity);

	UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
																										  type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalMotionEffect.minimumRelativeValue = @(-self.parallaxIntensity);
	horizontalMotionEffect.maximumRelativeValue = @(self.parallaxIntensity);

	UIMotionEffectGroup *group = [UIMotionEffectGroup new];
	group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];

	if (MIN(self.bounds.size.height, self.bounds.size.width) > 0.0f) {
		CGFloat smallSide = MIN(self.bounds.size.height, self.bounds.size.width);
		CGFloat parallaxScale = (smallSide + 2 * self.parallaxIntensity) / smallSide;
		CGAffineTransform transform = CGAffineTransformMakeScale(parallaxScale, parallaxScale);
		self.layer.transform = CATransform3DMakeAffineTransform(transform);
	}

//	@weakify(self);
//	[RACObserve(self, bounds) subscribeNext:^(id x) {
//		@strongify(self);
//		if (MIN(self.bounds.size.height, self.bounds.size.width) > 0.0f) {
//			CGFloat smallSide = MIN(self.bounds.size.height, self.bounds.size.width);
//			CGFloat parallaxScale = (smallSide + 2 * self.parallaxIntensity) / smallSide;
//			CGAffineTransform transform = CGAffineTransformMakeScale(parallaxScale, parallaxScale);
//			self.layer.transform = CATransform3DMakeAffineTransform(transform);
//		}
//	}];
//
	[self addMotionEffect:group];
}


+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];

		SEL originalSelector = @selector(setBounds:);
		SEL swizzledSelector = @selector(swizzledSetBounds:);

		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

		// When swizzling a class method, use the following:
		// Class class = object_getClass((id)self);
		// ...
		// Method originalMethod = class_getClassMethod(class, originalSelector);
		// Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

		BOOL didAddMethod =
		class_addMethod(class,
						originalSelector,
						method_getImplementation(swizzledMethod),
						method_getTypeEncoding(swizzledMethod));

		if (didAddMethod) {
			class_replaceMethod(class,
								swizzledSelector,
								method_getImplementation(originalMethod),
								method_getTypeEncoding(originalMethod));
		} else {
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	});
}

- (void)swizzledSetBounds:(CGRect)bounds {
	[self swizzledSetBounds:bounds];
	if (self.parallaxIntensity > FLT_EPSILON && MIN(self.bounds.size.height, self.bounds.size.width) > 0.0f) {
		CGFloat smallSide = MIN(self.bounds.size.height, self.bounds.size.width);
		CGFloat parallaxScale = (smallSide + 2 * self.parallaxIntensity) / smallSide;
		CGAffineTransform transform = CGAffineTransformMakeScale(parallaxScale, parallaxScale);
		self.layer.transform = CATransform3DMakeAffineTransform(transform);
	}
}

@end
