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
