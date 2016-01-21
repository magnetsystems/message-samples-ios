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

#import "MMDeviceStatus.h"
#import "MMOsType.h"
#import "MMPushAuthorityType.h"
#import "MMModel.h"

/**
 The MMDevice class is a local representation of a device in the MagnetMax platform. This class provides various device specific methods, like updating the device (APNs) token.
 */
@interface MMDevice : MMModel

/**
 The unique identifer for the device.
 */
@property (nonatomic, copy) NSString *deviceID;

/**
 The owner for the device.
 */
@property (nonatomic, copy) NSString *userID;

/**
 The tags associated with the device.
 */
@property (nonatomic, strong) NSArray <NSString *>*tags;

/**
 The OS for the device.
 */
@property (nonatomic, assign) MMOsType os;

/**
 The OS version for the device.
 */
@property (nonatomic, copy) NSString *osVersion;

/**
 The token for the device.
 */
@property (nonatomic, copy) NSString *deviceToken;

/**
 The status for the device.
 */
@property (nonatomic, assign) MMDeviceStatus deviceStatus;

/**
 The label for the device.
 */
@property (nonatomic, copy) NSString *label;

/**
 The push authority for the device.
 */
@property (nonatomic, assign) MMPushAuthorityType pushAuthority;

@end
