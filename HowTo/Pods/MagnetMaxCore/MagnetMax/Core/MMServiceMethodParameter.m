/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
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