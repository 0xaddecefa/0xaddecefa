//
//  AppDelegate.m
//  buster
//
//  Created by Tamas Nemeth on 05/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "AppDelegate.h"
#import "TNBNetworkManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


	[[TNBNetworkManager sharedInstance] getConfigurationWithCompletion:^(TNBNetworkRequest *operation, id responseObject) {
	}];

	[[TNBNetworkManager sharedInstance] search:@"the b" page:1 complete:^(TNBNetworkRequest *operation, id responseObject) {
		int i = 0;
	} fail:^(TNBNetworkRequest *request, NSError *error) {
		int i = 0;
	}];

	return YES;
}

@end
