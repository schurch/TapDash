//
//  AppDelegate.h
//  TapDash
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright Stefan Church 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
