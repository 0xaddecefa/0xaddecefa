//
//  AppDelegate.m
//  buster
//
//  Created by Tamas Nemeth on 05/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "AppDelegate.h"
#import "TNBImageManager.h"
#import "TNBMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[TNBImageManager sharedInstance];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TNBMainViewController *mainViewController = [[TNBMainViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	self.window.rootViewController = navController;
	[self.window makeKeyAndVisible];

	return YES;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TNBImageManager sharedInstance] clearMemoryCache];
}

@end
