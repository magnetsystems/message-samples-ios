/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMOsType.h"

@implementation MMOsTypeContainer

+ (NSDictionary *)mappings {
  return @{ 
      @"ANDROID" : @(MMOsTypeANDROID), 
      @"IOS" : @(MMOsTypeIOS), 
      @"OTHER" : @(MMOsTypeOTHER), 
      @"WINDOWS" : @(MMOsTypeWINDOWS)
  };
}

@end