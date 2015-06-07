//
//  NSObject+Multithreading.h
//
//  Created by Tamas Nemeth on 4/19/12.
//

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

@interface NSObject(Multithreading)

- (void)performBlock:(void(^)(void))blk onThread:(NSThread*)thread;
- (void)performBlockOnMainThread:(void(^)(void))blk;
- (void)performBlock:(void(^)(void))blk onThread:(NSThread*)thread waitUntilDone:(BOOL) waitUntilDone;
- (void)performBlockOnMainThread:(void(^)(void))blk waitUntilDone:(BOOL) waitUntilDone;
- (void)performBlock:(void(^)(void))blk;

@end
