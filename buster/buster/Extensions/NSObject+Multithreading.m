//
//  NSObject+Multithreading.m
//
//  Created by Tamas Nemeth on 4/19/12.
//

#import "NSObject+Multithreading.h"

@implementation NSObject(Multithreading)

- (void)performBlock:(void(^)(void))blk {
	blk();
}

- (void)performBlock:(void(^)(void))blk onThread:(NSThread*)thread {
	if ([[NSThread currentThread] isEqual:thread]) {
		[self performBlock:blk];
	} else {
		[self performSelector:@selector(performBlock:) onThread:thread withObject:[blk copy] waitUntilDone:NO];
	}
}

- (void)performBlockOnMainThread:(void(^)(void))blk {
	[self performBlock:blk onThread:[NSThread mainThread]];
}

- (void)performBlock:(void(^)(void))blk onThread:(NSThread*)thread waitUntilDone:(BOOL) waitUntilDone {
	if ([[NSThread currentThread] isEqual:thread]) {
		[self performBlock:blk];
	} else {
		[self performSelector:@selector(performBlock:) onThread:thread withObject:[blk copy] waitUntilDone:waitUntilDone];
	}
}

- (void)performBlockOnMainThread:(void(^)(void))blk waitUntilDone:(BOOL) waitUntilDone {
	[self performBlock:blk onThread:[NSThread mainThread] waitUntilDone:waitUntilDone];
}

@end
