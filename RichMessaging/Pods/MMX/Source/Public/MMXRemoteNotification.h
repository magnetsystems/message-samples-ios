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


@interface MMXRemoteNotification : NSObject

/**
 *	Method to identify if the notification was sent from the Magnet Message Server.
 *
 *  @param userInfo - The remote notification.
 *
 *  @return YES if the remote notification is sent by MMX.
 */
+ (BOOL)isMMXRemoteNotification:(NSDictionary *)userInfo;

/**
 *	Method to identify if the purpose of the notification is to initiate a wakeup of the application.
 *
 *	@param userInfo - The remote notification.
 *
 *  @return YES if the remote notification is sent by MMX.
 */
+ (BOOL)isWakeupRemoteNotification:(NSDictionary *)userInfo;

/**
 *  Method to acknowledge that the app received a MMX remote notification.
 *
 *  @param userInfo    - The remote notification.
 *  @param completion  - Block with BOOL. Value should be YES.
 */
+ (void)acknowledgeRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL success))completion;

@end