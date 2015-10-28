/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMUserRealm.h"

@implementation MMUserRealmContainer

+ (NSDictionary *)mappings {
    return @{
             @"AD" : @(MMUserRealmAD),
             @"DB" : @(MMUserRealmDB),
             @"FACEBOOK" : @(MMUserRealmFACEBOOK),
             @"GOOGLEPLUS" : @(MMUserRealmGOOGLEPLUS),
             @"LDAP" : @(MMUserRealmLDAP),
             @"OTHER" : @(MMUserRealmOTHER),
             @"TWITTER" : @(MMUserRealmTWITTER),
             @"WORDPRESS" : @(MMUserRealmWORDPRESS)
             };
}


@end