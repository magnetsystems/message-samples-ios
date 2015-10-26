/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMServiceIOType.h"
#import "MMServiceMethodParameterType.h"

@protocol MMEnumAttributeContainer;


@interface MMServiceMethodParameter : NSObject

@property(nonatomic, copy) NSString *name;

@property(nonatomic, assign) BOOL isOptional;

@property(nonatomic, assign) MMServiceIOType type;

@property(nonatomic, assign) MMServiceIOType componentType;

// This is only available if the type is a Model, collection of Model objects or an enum
@property(nonatomic, strong) Class<MMEnumAttributeContainer> typeClass;

@property(nonatomic, assign) MMServiceMethodParameterType requestParameterType;

@property(nonatomic, readonly) BOOL isComplex;

@end
