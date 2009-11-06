//
//  GrowlDemoViewController.m
//  GrowlDemo
//
//  Created by Zsombor Szabó on 11/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GrowlDemoViewController.h"

@implementation GrowlDemoViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (IBAction)popupSampleGrowlNotification
{
	IZGrowlNotification *notification = [[IZGrowlNotification alloc] initWithTitle:@"Tip" 
																	   description:@"Shake the device to reset the route" 
																			 image:[UIImage imageNamed:@"information-symbol.png"] 
																		   context:nil 
																		  delegate:self];
	[[IZGrowlManager sharedManager] postNotification:notification];
	[notification release];	
}

- (void)didSingleTapOnNotification:(IZGrowlNotification *)aNotification
{
	IZGrowlNotification *notification = [[IZGrowlNotification alloc] initWithTitle:@"Question" 
																	   description:@"Why did you push the button Dee Dee?" 
																			 image:[UIImage imageNamed:@"information-symbol.png"] 
																		   context:nil 
																		  delegate:self];
	[[IZGrowlManager sharedManager] postNotification:notification];
	[notification release];		
}

@end
