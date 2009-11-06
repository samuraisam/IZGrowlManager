/*
 Copyright (C) 2009 Zsombor Szabó, IZE Ltd.. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "IZGrowlManager.h"

#pragma mark -
#pragma mark IZGrowlNotification

@implementation IZGrowlNotification

@synthesize title, description, image, context, delegate;

- (id)initWithTitle:(NSString *)theTitle 
		description:(NSString *)theDescription 
			  image:(UIImage *)theImage 
			context:(id)theContext 
		   delegate:(id<NSObject, IZGrowlNotificationDelegate>)theDelegate
{
	if (self = [super init])
	{
		self.title = theTitle;
		self.description = theDescription;
		self.image = theImage;
		self.context = theContext;
		self.delegate = theDelegate;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.description = nil;
	self.image = nil;
	self.context = nil;
	self.delegate = nil;
	[super dealloc];
}

@end

#pragma mark -
#pragma mark IZGrowlNotificationButton

@interface IZGrowlNotificationButton : UIButton {
	IZGrowlNotification								*notification;
	NSNumber										*positionIndex;
	id<NSObject, IZGrowlNotificationButtonDelegate> delegate;
}

@property(nonatomic, retain) IZGrowlNotification *notification;
@property(nonatomic, retain) NSNumber *positionIndex;
@property(nonatomic, assign) id<NSObject, IZGrowlNotificationButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame notification:(IZGrowlNotification *)theNotification;

@end

@implementation IZGrowlNotificationButton

@synthesize notification, positionIndex, delegate;

- (id)initWithFrame:(CGRect)frame notification:(IZGrowlNotification *)theNotification
{
	if (self = [super initWithFrame:frame])
	{
		self.notification = theNotification;
		self.positionIndex = nil;
		
		UIImage *closeButtonImage = [UIImage imageNamed:@"growl-close-button.png"];
		// Because the image is too little (24x24) the user won't be able to tap on this button. Let's make it have a bigger (40x40) frame.
		CGRect closeButtonFrame = CGRectMake(0, 0, 40, 40); 
		closeButtonFrame.origin.x = 18-20;
		closeButtonFrame.origin.y = 18-20;
		UIButton *closeButton = [[UIButton alloc] initWithFrame:closeButtonFrame];
		[closeButton setImage:closeButtonImage forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(tappedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];
		[closeButton release];		
	}
	return self;
}

- (void)tappedCloseButton:(id)sender
{
	if ([self.delegate respondsToSelector:@selector(didTapOnCloseButton:)])
		[self.delegate didTapOnCloseButton:self];
}

- (void)dealloc
{
	self.notification = nil;
	self.positionIndex = nil;
	self.delegate = nil;
	[super dealloc];
}

@end

#pragma mark -
#pragma mark IZGrowlManager

#define kDefaultFadeInTime 0.1
#define kDefaultFadeOutTime 0.1
#define kDefaultDisplayTime 3
#define kMaxDisplayedNotifications 3

@implementation IZGrowlManager

@synthesize window;
@synthesize fadeInTime;
@synthesize fadeOutTime;
@synthesize displayTime;
@synthesize offset;
@synthesize displayedNotifications;

static IZGrowlManager *sharedManager = nil;

+ (IZGrowlManager *)sharedManager
{
    @synchronized(self) 
	{
        if (sharedManager == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if (sharedManager == nil) 
		{
            sharedManager = [super allocWithZone:zone];
            return sharedManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
	if (self = [super init])
	{
		self.fadeInTime = kDefaultFadeInTime;
		self.fadeOutTime = kDefaultFadeOutTime;
		self.displayTime = kDefaultDisplayTime;
		self.offset = CGPointMake(-5, -41);
		self.window = [[UIApplication sharedApplication] keyWindow]; // By default use the current keyWindow of the application
		
		displayedNotifications = 0;
		
		reuseableButtons = [[NSMutableSet alloc] init];		
		notificationQueue = [[NSMutableArray alloc] init];		
		occupiedPositions = [[NSMutableSet alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveUIApplicationDidReceiveMemoryWarningNotification:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];		
	}
	return self;
}

- (void)dealloc
{
	self.window = nil;
	[reuseableButtons release];
	[notificationQueue release];
	[occupiedPositions release];
	[super dealloc];
}

- (void)didReceiveUIApplicationDidReceiveMemoryWarningNotification:(NSNotification *)info
{
	[reuseableButtons removeAllObjects];
}

#define kTitleLabelTag 1
#define kDescriptionLabelTag 2
#define kImageViewTag 3

#define kButtonWidth 244
#define kButtonHeight 75

- (IZGrowlNotificationButton *)constructButton
{
	IZGrowlNotificationButton *button = [[IZGrowlNotificationButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight) notification:nil];
	button.delegate = self; // To receive message when the X button is tapped
	
	UIImage *normalBackgroundImage = [UIImage imageNamed:@"growl-box.png"];
	normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:normalBackgroundImage.size.width/2 topCapHeight:normalBackgroundImage.size.height/2];
	[button setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
	
	UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"growl-box-highlighted.png"];
	highlightedBackgroundImage = [highlightedBackgroundImage stretchableImageWithLeftCapWidth:highlightedBackgroundImage.size.width/2 topCapHeight:highlightedBackgroundImage.size.height/2];
	[button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
	
#define ImageWidth 30
	
	CGRect imageViewRect = CGRectMake(9, kButtonHeight-7-ImageWidth, ImageWidth, ImageWidth);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.contentMode = UIViewContentModeScaleToFill; // This is the default setting, but let's be sure...
	imageView.tag = kImageViewTag;
	[button addSubview:imageView];
	[imageView release];
	
#define TopOffset2 5
#define FontSize 14.5
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, TopOffset2, kButtonWidth-(51+6), 22)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.tag = kTitleLabelTag;
	titleLabel.textAlignment = UITextAlignmentLeft;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor blackColor];
	titleLabel.shadowOffset = CGSizeMake(0, 1);
	titleLabel.font = [UIFont boldSystemFontOfSize:FontSize];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.minimumFontSize = 10;
	[button addSubview:titleLabel];
	[titleLabel release];	
	
	UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, TopOffset2+22+5, kButtonWidth-(51+6), kButtonHeight-(TopOffset2+22+5+7))];
	descriptionLabel.tag = kDescriptionLabelTag;
	descriptionLabel.backgroundColor = [UIColor clearColor];
	descriptionLabel.textAlignment = UITextAlignmentLeft;
	descriptionLabel.textColor = [UIColor whiteColor];
	descriptionLabel.shadowColor = [UIColor blackColor];
	descriptionLabel.shadowOffset = CGSizeMake(0, 1);
	descriptionLabel.font = [UIFont systemFontOfSize:FontSize];
	descriptionLabel.numberOfLines = 2;
	[button addSubview:descriptionLabel];
	[descriptionLabel release];	
	
	[button addTarget:self action:@selector(highlightedButton:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(notHighlightedButton:) forControlEvents:UIControlEventTouchDragExit];
	[button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	return [button autorelease];
}

- (IZGrowlNotificationButton *)dequeueReusableButton
{
    IZGrowlNotificationButton *button = [reuseableButtons anyObject];
    if (button) 
	{
        [[button retain] autorelease];
        [reuseableButtons removeObject:button];
    }
    return button;
}

// This is needed for KVO compliancy
- (void)setDisplayedNotifications:(NSInteger)newValue
{
	if (self.displayedNotifications != newValue)
	{
		[self willChangeValueForKey:@"displayedNotifications"];
		displayedNotifications = newValue;
		[self didChangeValueForKey:@"displayedNotifications"];
	}
}

- (void)doPostNotification:(IZGrowlNotification *)notification
{
	self.displayedNotifications++;
	
	IZGrowlNotificationButton *button = [self dequeueReusableButton];
	if (button == nil)
		button = [self constructButton];
	
	// Setup the button
	UILabel *titleLabel = (UILabel *)[button viewWithTag:kTitleLabelTag];
	titleLabel.text = notification.title;
	UIImageView *imageView = (UIImageView *)[button viewWithTag:kImageViewTag];
	imageView.image = notification.image;
	UILabel *descriptionLabel = (UILabel *)[button viewWithTag:kDescriptionLabelTag];
	descriptionLabel.text = notification.description;
	
	button.notification = notification;
	
	// Determine the position with the smallest index which is free on the screen
	NSNumber *position = nil;
	for (int i=0; i<kMaxDisplayedNotifications; i++)
	{
		position = [NSNumber numberWithInt:i];
		if ([occupiedPositions member:position] == nil)
			break;
	}
	
	if (position == nil) // Can't really be nil, but what the heck...
	{
		return;
		//NSLog(@"here");
	}

	// Now display the notification to the user
	[occupiedPositions addObject:position];
	CGRect rect = button.frame;
#define kDistanceBetweenNotificationBubbles 5
	rect.origin.x = self.window.bounds.size.width-rect.size.width+offset.x;
	rect.origin.y = self.window.bounds.size.height+offset.y-([position intValue]+1)*(rect.size.height+kDistanceBetweenNotificationBubbles);
	button.frame = rect;
	button.positionIndex = position;
	
	button.alpha = 0.;
	[self.window addSubview:button];
	
	[UIView beginAnimations:@"fadeInAnimation" context:nil];
	[UIView setAnimationDuration:self.fadeInTime];
	button.alpha = 1.;
	[UIView commitAnimations];
	
	[self performSelector:@selector(fadeOutButton:) withObject:button afterDelay:self.fadeInTime+self.displayTime];
}

- (void)fadeOutButton:(IZGrowlNotificationButton *)button
{
	[UIView beginAnimations:@"fadeOutAnimation" context:nil];
	[UIView setAnimationDuration:self.fadeOutTime];
	button.alpha = 0.;
	[UIView commitAnimations];
	
	[self performSelector:@selector(removeButton:) withObject:button afterDelay:self.fadeOutTime];
}

- (void)removeButton:(IZGrowlNotificationButton *)button
{
	self.displayedNotifications--;
	
	[occupiedPositions removeObject:button.positionIndex];
	[reuseableButtons addObject:button];
	[button removeFromSuperview];
	
	// Post another notification if it is in our queue
	if ([notificationQueue count] > 0)
	{
		IZGrowlNotification *notification = [notificationQueue objectAtIndex:0];
		[self postNotification:notification];
		[notificationQueue removeObject:notification];
	}
}

// IZGrowlNotificationButtonDelegate method
- (void)didTapOnCloseButton:(IZGrowlNotificationButton *)button
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutButton:) object:button];
	[self performSelector:@selector(fadeOutButton:) withObject:button afterDelay:self.fadeOutTime];
}

- (void)tappedButton:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutButton:) object:sender];
	[self fadeOutButton:sender]; // Fade out. Now.
	
	IZGrowlNotificationButton *button = (IZGrowlNotificationButton *)sender;
	if ([button.notification.delegate respondsToSelector:@selector(didSingleTapOnNotification:)])
		[button.notification.delegate didSingleTapOnNotification:button.notification];
}

- (void)highlightedButton:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutButton:) object:sender];
}

- (void)notHighlightedButton:(id)sender
{
	[self fadeOutButton:sender]; // Fade out. Now.
}

#pragma mark -
#pragma mark Public

- (void)postNotification:(IZGrowlNotification *)notification
{
	if (self.displayedNotifications >= kMaxDisplayedNotifications)
		[notificationQueue addObject:notification];
	else
		[self doPostNotification:notification];
}

@end
