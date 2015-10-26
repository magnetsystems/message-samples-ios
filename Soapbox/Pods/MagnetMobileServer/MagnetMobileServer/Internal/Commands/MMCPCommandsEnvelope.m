/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPCommandsEnvelope.h"
#import "MMCPCommand.h"


@implementation MMCPCommandsEnvelope

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                            @"commands" : @"commands",
                                                                                            }];
}

#pragma mark -

+ (NSValueTransformer *)commandsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MMCPCommand.class];
}

@end