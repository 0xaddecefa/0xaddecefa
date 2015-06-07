//
//  AppDelegate.m
//  buster
//
//  Created by Tamas Nemeth on 05/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "AppDelegate.h"
#import "TNBNetworkManager.h"
#import "TNBMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TNBMainViewController *mainViewController = [[TNBMainViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	self.window.rootViewController = navController;
	[self.window makeKeyAndVisible];

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
