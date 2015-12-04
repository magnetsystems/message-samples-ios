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

@class MMServiceAdapter;


@interface MMService : NSObject

+ (NSDictionary *)metaData;

/**
 * Posted when an invalid set of clientID/clientSecret are used to configure MagnetMax. This event can be used to prompt the user to re-download the app. One possibility is that the keys were revoked.
 */
extern NSString *const MMApplicationDidReceiveAuthenticationChallengeNotification;

/**
 * Posted when an end-user needs to attempt login. This event can be used to prompt the user to login again.
 */
extern NSString *const MMUserDidReceiveAuthenticationChallengeNotification;

@end
