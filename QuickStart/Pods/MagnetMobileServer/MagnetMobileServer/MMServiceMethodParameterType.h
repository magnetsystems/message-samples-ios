/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MMServiceMethodParameterType){
    MMServiceMethodParameterTypeHeader,
    MMServiceMethodParameterTypePath,
    MMServiceMethodParameterTypeQuery,
    MMServiceMethodParameterTypeForm,
    MMServiceMethodParameterTypeBody,
    MMServiceMethodParameterTypeFormData,
};
