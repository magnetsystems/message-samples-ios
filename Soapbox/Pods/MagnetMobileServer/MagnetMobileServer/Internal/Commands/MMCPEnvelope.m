/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPEnvelope.h"


@implementation MMCPEnvelope

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"requestId": @"id",
            @"sessionId": @"sid",
            @"operationType": @"op",
            @"timestamp": @"stm",
            @"sender": @"sender",
    };
}

#pragma mark -

+ (NSValueTransformer *)operationTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"REQUEST" : @(MMCPOperationTypeRequest),
            @"RESPONSE" : @(MMCPOperationTypeResponse),
            @"ACK_CONNECTED" : @(MMCPOperationTypeAckConnected),
            @"ACK_RECEIVED" : @(MMCPOperationTypeAckReceived),
    }];
}

@end