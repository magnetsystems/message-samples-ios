/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMEnumAttributeContainer.h"

typedef NS_ENUM(NSUInteger, MMTimeUnit){
  MMTimeUnitDAYS = 0,
  MMTimeUnitHOURS,
  MMTimeUnitMICROSECONDS,
  MMTimeUnitMILLISECONDS,
  MMTimeUnitMINUTES,
  MMTimeUnitNANOSECONDS,
  MMTimeUnitSECONDS,
};

@interface MMTimeUnitContainer : NSObject <MMEnumAttributeContainer>

@end