/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
