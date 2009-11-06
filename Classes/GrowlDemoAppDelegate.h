//
//  GrowlDemoAppDelegate.h
//  GrowlDemo
//
//  Created by Zsombor Szabó on 11/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowlDemoViewController;

@interface GrowlDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GrowlDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GrowlDemoViewController *viewController;

@end

