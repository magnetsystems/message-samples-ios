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
#import "MMXAddressable.h"
@class MMXUserID;

/**
 *  MMXUserProfile is used to hold additional information about a user.
 */
@interface MMXUserProfile : NSObject <NSCoding, MMXAddressable>

/**
 *  The MMXUserID for the user.
 *  MMXUserID is one way to address a message to a user.
 */
@property  (nonatomic, readonly) MMXUserID *userID;

/**
 *  The name you want to have publicly displayed for the user.
 *  The valid character set is alphanumeric plus period, dash and underscore. .-_
 */
@property  (nonatomic, readwrite) NSString *displayName;

/**
 *  The email for the user.
 */
@property  (nonatomic, readwrite) NSString *email;

//MMXAddressable Protocol
@property (nonatomic, readonly) MMXInternalAddress *address;

@end
