/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
