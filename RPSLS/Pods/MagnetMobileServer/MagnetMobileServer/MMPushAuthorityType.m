/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMPushAuthorityType.h"

@implementation MMPushAuthorityTypeContainer

+ (NSDictionary *)mappings {
  return @{ 
      @"APNS" : @(MMPushAuthorityTypeAPNS), 
      @"GCM" : @(MMPushAuthorityTypeGCM), 
      @"OTHERS" : @(MMPushAuthorityTypeOTHERS)
  };
}

@end