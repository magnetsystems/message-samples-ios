/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
@import Mantle;

@interface MMModel : MTLModel<MTLJSONSerializing>

/** The node type. */

+ (NSDictionary *)attributeMappings;

+ (NSDictionary *)listAttributeTypes;

+ (NSDictionary *)mapAttributeTypes;

+ (NSDictionary *)enumAttributeTypes;

+ (NSArray *)charAttributes;
@end
