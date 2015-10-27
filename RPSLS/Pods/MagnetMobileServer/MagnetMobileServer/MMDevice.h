/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMDeviceStatus.h"
#import "MMOsType.h"
#import "MMPushAuthorityType.h"
#import "MMModel.h"

@interface MMDevice : MMModel


@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, assign) MMOsType  os;

@property (nonatomic, copy) NSString *osVersion;

@property (nonatomic, copy) NSString *deviceToken;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, assign) MMDeviceStatus  deviceStatus;

@property (nonatomic, copy) NSString *label;

@property (nonatomic, assign) MMPushAuthorityType  pushAuthority;

@property (nonatomic, copy) NSString *deviceId;

@end
