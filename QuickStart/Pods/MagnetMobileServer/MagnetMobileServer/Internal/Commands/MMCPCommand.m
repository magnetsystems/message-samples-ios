/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPCommand.h"
#import "MMCPHTTPPayload.h"
#import "MMCPExecuteApiCommand.h"
#import "MMCPExecuteApiResCommand.h"


@implementation MMCPCommand

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"commandId" : @"cid",
            @"name" : @"name",
            @"priority" : @"priority",
            @"payload" : @"payload",
    };
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {

    if ([JSONDictionary[@"name"] isEqualToString:@"executeapicommand"]) {
        return MMCPExecuteApiCommand.class;
    }

    if ([JSONDictionary[@"name"] isEqualToString:@"executeapicommandres"]) {
        return MMCPExecuteApiResCommand.class;
    }

    NSAssert(NO, @"No matching class for the JSON dictionary '%@'.", JSONDictionary);
    return self;
}

#pragma mark -

+ (NSValueTransformer *)priorityJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"HIGH" : @(MMCPPriorityHigh),
            @"MEDIUM" : @(MMCPPriorityMedium),
            @"LOW" : @(MMCPPriorityLow),
    }];
}

+ (NSValueTransformer *)payloadJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:MMCPHTTPPayload.class];
}

@end