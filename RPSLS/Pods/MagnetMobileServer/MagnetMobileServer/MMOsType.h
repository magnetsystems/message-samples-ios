/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
//@import MagnetMobileServer;
#import "MMEnumAttributeContainer.h"

typedef NS_ENUM(NSUInteger, MMOsType){
  MMOsTypeANDROID = 0,
  MMOsTypeIOS,
  MMOsTypeOTHER,
  MMOsTypeWINDOWS,
};

@interface MMOsTypeContainer : NSObject <MMEnumAttributeContainer>

@end