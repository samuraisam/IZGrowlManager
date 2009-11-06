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

#import <Foundation/Foundation.h>

@class IZGrowlNotification;

@protocol IZGrowlNotificationDelegate
@optional
- (void)didSingleTapOnNotification:(IZGrowlNotification *)notification;
@end

@interface IZGrowlNotification : NSObject {
	NSString									*title;
	NSString									*description;
	UIImage										*image;
	id											context;
	id<NSObject, IZGrowlNotificationDelegate>	delegate;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) UIImage *image; // The image to be displayed in the growl notification bubble. It will be displayed in 30x30 size.
@property(nonatomic, retain) id context; // Pass anything here
@property(nonatomic, assign) id<NSObject, IZGrowlNotificationDelegate> delegate;

- (id)initWithTitle:(NSString *)theTitle 
		description:(NSString *)theDescription 
			  image:(UIImage *)theImage 
			context:(id)theContext 
		   delegate:(id<IZGrowlNotificationDelegate>)theDelegate;

@end

@class IZGrowlNotificationButton;
@protocol IZGrowlNotificationButtonDelegate
@optional
- (void)didTapOnCloseButton:(IZGrowlNotificationButton *)button;
@end

@interface IZGrowlManager : NSObject <IZGrowlNotificationButtonDelegate> {
	UIWindow				*window;
	NSTimeInterval			fadeInTime;
	NSTimeInterval			fadeOutTime;
	NSTimeInterval			displayTime;
	CGPoint					offset;
	NSInteger				displayedNotifications;
	
	NSMutableSet			*reuseableButtons;
	NSMutableArray			*notificationQueue;
	NSMutableSet			*occupiedPositions;
}

+ (IZGrowlManager *)sharedManager;

@property(nonatomic, retain) UIWindow *window; // The window in which to display the Growl notifications. Default [[UIApplication sharedApplication] keyWindow]
@property(nonatomic, assign) NSTimeInterval fadeInTime; // Default value 0.1
@property(nonatomic, assign) NSTimeInterval fadeOutTime; // Default value 0.1
@property(nonatomic, assign) NSTimeInterval displayTime; // Default value 3
@property(nonatomic, assign) CGPoint offset; // The offset from the bottom right corner. Default {-5, -41}
@property(nonatomic, assign, readonly) NSInteger displayedNotifications; // Currently displayed notifications count

- (void)postNotification:(IZGrowlNotification *)notification;

@end
