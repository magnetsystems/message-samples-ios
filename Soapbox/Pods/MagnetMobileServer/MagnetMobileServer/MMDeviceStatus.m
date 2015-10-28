/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMDeviceStatus.h"

@implementation MMDeviceStatusContainer

+ (NSDictionary *)mappings {
  return @{ 
      @"ACTIVE" : @(MMDeviceStatusACTIVE), 
      @"CREATED" : @(MMDeviceStatusCREATED), 
      @"INACTIVE" : @(MMDeviceStatusINACTIVE)
  };
}

@end