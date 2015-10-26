/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMServiceMethod.h"


@implementation MMServiceMethod

#pragma mark - Overriden getters

- (BOOL)doesReturnString {
    BOOL doesReturnString = NO;

    switch (self.returnType) {

        case MMServiceIOTypeVoid:
        case MMServiceIOTypeString:
        case MMServiceIOTypeEnum:
        case MMServiceIOTypeBoolean:
        case MMServiceIOTypeChar:
        case MMServiceIOTypeUnichar:
        case MMServiceIOTypeShort:
        case MMServiceIOTypeInteger:
        case MMServiceIOTypeLongLong:
        case MMServiceIOTypeFloat:
        case MMServiceIOTypeDouble:
        case MMServiceIOTypeBigDecimal:
        case MMServiceIOTypeBigInteger:
        case MMServiceIOTypeDate:
        case MMServiceIOTypeUri: {
            doesReturnString = YES;
            break;
        };
        case MMServiceIOTypeArray:break;
        case MMServiceIOTypeDictionary:break;
        case MMServiceIOTypeData:break;
        case MMServiceIOTypeBytes:break;
        case MMServiceIOTypeMagnetNode:break;
    }

    return doesReturnString;
}


@end