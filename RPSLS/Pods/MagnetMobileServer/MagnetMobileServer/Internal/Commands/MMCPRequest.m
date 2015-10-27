/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPRequest.h"


@implementation MMCPRequest

#pragma mark - Overriden getters

- (MMCPOperationType)operationType {
    return MMCPOperationTypeRequest;
}

- (long long)timestamp {
    return (long long int) floor(([[NSDate date] timeIntervalSince1970] * 1000));
}

- (NSString *)sender {
    return @"Magnet iOS SDK";
}

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
            @"executionType" : @"execution",
            @"priority" : @"priority",
    }];
}

#pragma mark -

+ (NSValueTransformer *)executionTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"PARALLEL" : @(MMCPExecutionTypeParallel),
            @"SEQUENCED" : @(MMCPExecutionTypeSequenced),
            @"PIPELINED" : @(MMCPExecutionTypePipelined),
    }];
}

+ (NSValueTransformer *)priorityJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            @"HIGH" : @(MMCPPriorityHigh),
            @"MEDIUM" : @(MMCPPriorityMedium),
            @"LOW" : @(MMCPPriorityLow),
    }];
}

@end