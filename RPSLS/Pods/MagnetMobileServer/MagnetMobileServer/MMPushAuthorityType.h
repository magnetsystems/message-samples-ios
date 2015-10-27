/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
//@import MagnetMobileServer;
#import "MMEnumAttributeContainer.h"

typedef NS_ENUM(NSUInteger, MMPushAuthorityType){
  MMPushAuthorityTypeAPNS = 0,
  MMPushAuthorityTypeGCM,
  MMPushAuthorityTypeOTHERS,
};

@interface MMPushAuthorityTypeContainer : NSObject <MMEnumAttributeContainer>

@end
