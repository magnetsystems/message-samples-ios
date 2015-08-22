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
#import <Mantle/Mantle.h>
@class MMXUserID;

/**
 *  The MMXEndpoint is a representation of a specific device for a user. 
 *	It is possible that a user could have multiple devices associated with them. The endpoint can be used to address a message to a device.
 */
@interface MMXEndpoint : MTLModel <MMXAddressable>

/**
 *	The MMXUserID for the user the device is associated with.
 */
@property (nonatomic, readonly) MMXUserID * userID;

/**
 *  Automatically assigned UUID for the device.
 */
@property (nonatomic, copy, readonly) NSString * deviceID;

//MMXAddressable Protocol
@property (nonatomic, readonly) MMXInternalAddress *address;

@end
