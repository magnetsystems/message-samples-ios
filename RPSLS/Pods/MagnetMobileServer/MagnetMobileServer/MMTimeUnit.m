/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMTimeUnit.h"

@implementation MMTimeUnitContainer

+ (NSDictionary *)mappings {
  return @{ 
      @"DAYS" : @(MMTimeUnitDAYS), 
      @"HOURS" : @(MMTimeUnitHOURS), 
      @"MICROSECONDS" : @(MMTimeUnitMICROSECONDS), 
      @"MILLISECONDS" : @(MMTimeUnitMILLISECONDS), 
      @"MINUTES" : @(MMTimeUnitMINUTES), 
      @"NANOSECONDS" : @(MMTimeUnitNANOSECONDS), 
      @"SECONDS" : @(MMTimeUnitSECONDS)
  };
}

@end