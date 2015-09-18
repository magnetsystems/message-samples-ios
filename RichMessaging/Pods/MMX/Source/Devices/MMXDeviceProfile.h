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
#import <Mantle/Mantle.h>
@class MMXEndpoint;

/**
 *  MMXDeviceProfile is the container for detailed information about a user's device(Assuming the infomation was previously given)
 */
@interface MMXDeviceProfile : MTLModel

/**
 *  An object that can be used to directly contact the device.
 *	It contains the automatically assigned UUID for the device.
 *	It also contains the MMXUserID for the user the device is associated with.
 */
@property  (nonatomic, readonly) MMXEndpoint *endpoint;

/**
 *  Automatically defaults to [UIDevice currentDevice].name
 *	Can be changed using the MMXDeviceManager
 */
@property  (nonatomic, readonly) NSString *displayName;

/**
 *  IOS.
 */
@property  (nonatomic, readonly) NSString *osType;

/**
 *  Automatically defaults to [UIDevice currentDevice].model
 */
@property  (nonatomic, readonly) NSString *modelInfo;

/**
 *  Automatically detected iOS version number as NSString.
 */
@property  (nonatomic, readonly) NSString *osVersion;

/**
 *  APNS
 */
@property  (nonatomic, readonly) NSString *pushType;

/**
 *  Token used for APNS if set using the deviceToken property of MMXClient
 */
@property  (nonatomic, readonly) NSString *pushToken;

/**
 *  Optional -
 */
@property  (nonatomic, readonly) NSString *phoneNumber;

/**
 *  Optional -
 */
@property  (nonatomic, readonly) NSString *carrierInfo;

@end
