//
//  GrowlDemoViewController.h
//  GrowlDemo
//
//  Created by Zsombor Szabó on 11/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IZGrowlManager.h"

@interface GrowlDemoViewController : UIViewController <IZGrowlNotificationDelegate>{

}

- (IBAction)popupSampleGrowlNotification;

@end

