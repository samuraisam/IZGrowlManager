//
//  GrowlDemoAppDelegate.m
//  GrowlDemo
//
//  Created by Zsombor Szabó on 11/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GrowlDemoAppDelegate.h"
#import "GrowlDemoViewController.h"

@implementation GrowlDemoAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
