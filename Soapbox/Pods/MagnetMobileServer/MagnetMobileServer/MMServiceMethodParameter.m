/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMServiceMethodParameter.h"
#import "MMEnumAttributeContainer.h"


@implementation MMServiceMethodParameter

#pragma mark - Overriden getters

- (BOOL)isComplex {
    BOOL isComplex = YES;

    switch (self.type) {

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
        case MMServiceIOTypeData:
        case MMServiceIOTypeBytes:
        case MMServiceIOTypeUri: {
            isComplex = NO;
            break;
        };
        case MMServiceIOTypeArray:break;
        case MMServiceIOTypeDictionary:break;
        case MMServiceIOTypeMagnetNode:break;
    }

    return isComplex;
}

@end