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
#import "MMServiceIOType.h"

@protocol MMEnumAttributeContainer;


@interface MMValueTransformer : NSValueTransformer

// Returns a transformer which transforms values using the given block, for
// forward or reverse transformations.

/**
 * convert date with format yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
 */
+ (instancetype)dateTransformer;

+ (instancetype)urlTransformer;

+ (instancetype)dataTransformer;

+ (instancetype)unicharTransformer;

+ (instancetype)floatTransformer;

+ (instancetype)doubleTransformer;

+ (instancetype)longLongTransformer;

+ (instancetype)booleanTransformer;

+ (instancetype)enumTransformerForContainerClass:(Class<MMEnumAttributeContainer>)containerClass;

+ (instancetype)resourceNodeTransformerForClass:(Class)clazz;

+ (instancetype)listTransformerForType:(MMServiceIOType)type clazz:(Class)clazz;

+ (instancetype)mapTransformerForType:(MMServiceIOType)type clazz:(Class)clazz;

+ (instancetype)bigDecimalTransformer;

@end
