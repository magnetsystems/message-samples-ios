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

#import <Foundation/Foundation.h>

#ifndef _MMSERVICEIOTYPE_
    #define _MMSERVICEIOTYPE_

typedef NS_ENUM(NSInteger, MMServiceIOType){
    MMServiceIOTypeVoid = 0,
    MMServiceIOTypeString,
    MMServiceIOTypeEnum,
    MMServiceIOTypeBoolean,
    MMServiceIOTypeChar, // byte in Java
    MMServiceIOTypeUnichar, // char in Java
    MMServiceIOTypeShort,
    MMServiceIOTypeInteger,
    MMServiceIOTypeLongLong, // long in Java
    MMServiceIOTypeFloat,
    MMServiceIOTypeDouble,
    MMServiceIOTypeBigDecimal, // TBD
    MMServiceIOTypeBigInteger, // TBD
    MMServiceIOTypeDate,
    MMServiceIOTypeUri, // TBD
    MMServiceIOTypeArray,
    MMServiceIOTypeDictionary,
    MMServiceIOTypeData, // TBD
    MMServiceIOTypeBytes, // TBD
    MMServiceIOTypeMagnetNode,
};

#endif /* _MMSERVICEIOTYPE_ */
