/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AppDelegate.h"
#import <MMX.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//You must include your Configurations.plist file in the project. You can download this file on the Settings page of the Magnet Message Console
	NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"];
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName], @"You must include your Configurations.plist file in the project. You can download this file on the Settings page of the Magnet Message Web Interface");
	//You need to change the bundle Identifier to match the one your push certificate is set up to work with.
	//Code to register for notifications
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
																						 UIUserNotificationTypeSound |
																						 UIUserNotificationTypeAlert) categories:nil];
	[application registerUserNotificationSettings:settings];

    [MMX setupWithConfiguration:@"default"];

	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//	[[MMXClient sharedClient] updateRemoteNotificationDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Please make sure you have followed the steps outlined on the following page to set up push notifications and use it with Magnet Message:\nhttps://docs.magnet.com/message/ios/set-up-apns/");
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
	//register to receive notifications
	[application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	
	//In the case of a silent notification use the following code to see if it is a wakeup notification
	if ([MMXRemoteNotification isWakeupRemoteNotification:userInfo]) {
		//Send local notification to the user or connect via MMXClient
		completionHandler(UIBackgroundFetchResultNewData);
	} else if ([MMXRemoteNotification isMMXRemoteNotification:userInfo]) {
		NSLog(@"userInfo = %@",userInfo);
		//Check if the message is designed to wake up the client
		[MMXRemoteNotification acknowledgeRemoteNotification:userInfo completion:^(BOOL success) {
			completionHandler(UIBackgroundFetchResultNewData);
		}];
	} else {
		completionHandler(UIBackgroundFetchResultNoData);
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [MMX teardown];
}

@end
