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
 Returns YES if the remote notification is sent by MMX.

 @param userInfo The remote notification.

 */
+ (BOOL)isMMXRemoteNotification:(NSDictionary *)userInfo;

/**
 Returns YES if the remote notification is for a wake-up.

 @param userInfo The remote notification.

 */
+ (BOOL)isWakeupRemoteNotification:(NSDictionary *)userInfo;

/**
 Acknowledges a MMX remote notification.

 @param userInfo The remote notification.

 */
+ (void)acknowledgeRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL success))completion;

@end