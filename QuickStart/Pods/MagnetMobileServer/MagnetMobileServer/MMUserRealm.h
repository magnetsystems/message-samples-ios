/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMEnumAttributeContainer.h"

typedef NS_ENUM(NSUInteger, MMUserRealm){
    MMUserRealmAD = 0,
    MMUserRealmDB,
    MMUserRealmFACEBOOK,
    MMUserRealmGOOGLEPLUS,
    MMUserRealmLDAP,
    MMUserRealmOTHER,
    MMUserRealmTWITTER,
    MMUserRealmWORDPRESS,
};

@interface MMUserRealmContainer : NSObject <MMEnumAttributeContainer>

@end
