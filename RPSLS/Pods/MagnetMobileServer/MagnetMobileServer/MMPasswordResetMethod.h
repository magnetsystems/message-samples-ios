/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMEnumAttributeContainer.h"

typedef NS_ENUM(NSUInteger, MMPasswordResetMethod){
    MMPasswordResetMethodNOTIFICATION = 0,
    MMPasswordResetMethodOLDPASSWORD,
    MMPasswordResetMethodOTP,
};

@interface MMPasswordResetMethodContainer : NSObject <MMEnumAttributeContainer>

@end
