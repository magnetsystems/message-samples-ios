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

/**
 *  The MMXUserID class is the primary way to identify a user, as well as a means to address a message to that user.
 */
@interface MMXUserID : NSObject <MMXAddressable>

/**
 *  The username associated with this object
 */
@property (nonatomic, readonly) NSString *username;

/**
 *  Convenience method to create a MMXUserID to send a message to
 *
 *  @param username - The username of the user you want to send a message to.
 *
 *  @return MMXUserID object
 */
+ (instancetype)userIDWithUsername:(NSString *)username;

//MMXAddressable Protocol
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) NSString *subAddress;

@end