/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
