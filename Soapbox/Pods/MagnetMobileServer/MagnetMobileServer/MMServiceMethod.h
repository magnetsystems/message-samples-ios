/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMHTTPUtilities.h"
#import "MMServiceIOType.h"


@interface MMServiceMethod : NSObject

@property(nonatomic, strong) Class clazz;

@property(nonatomic, assign) SEL selector;

@property(nonatomic, copy) NSString *path;

@property(nonatomic, assign) MMRequestMethod requestMethod;

@property(nonatomic, assign) MMServiceIOType returnType;

@property(nonatomic, assign) MMServiceIOType returnComponentType;

// This is only available if the returnType is a Model or a collection of Model objects
@property(nonatomic, strong) Class returnTypeClass;

@property(nonatomic, copy) NSArray *parameters;

@property(nonatomic, readonly) BOOL doesReturnString;

@property(nonatomic, copy) NSSet *produces;

@property(nonatomic, copy) NSSet *consumes;

@end
