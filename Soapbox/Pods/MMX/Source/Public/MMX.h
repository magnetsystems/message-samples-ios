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

#import <Foundation/Foundation.h>
#import "MMXMessage.h"
#import "MMXChannel.h"
#import "MMXInvite.h"
#import "MMXInviteResponse.h"
#import "MMXUser.h"
#import "MMXNotificationConstants.h"
#import "MMXMessageTypes.h"
#import "MMXLogger.h"
#import "MMXRemoteNotification.h"

@interface MMX : NSObject

/**
 *  Initialize MMX with a configuration
 *
 *  @param name The name of the configuration in your Configurations.plist file that you want to connect to.
 */
+ (void)setupWithConfiguration:(NSString *)name;

/**
 *  Call when no longer need to use the MMX features or when the app goes to the background
 */
+ (void)teardown;

/**
 *  You must enable incoming messages. It is disabled by default.
 */
+ (void)enableIncomingMessages;

/**
 *  Disable incoming messages.
 */
+ (void)disableIncomingMessages;

/**
 *  Updates the device token.
 *
 *  @param deviceToken - Returned in AppDelegate application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
+ (void)setRemoteNotificationDeviceToken:(NSData *)deviceToken;

@end
