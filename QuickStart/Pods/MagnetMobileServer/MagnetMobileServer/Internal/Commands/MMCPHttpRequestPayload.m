/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPHTTPRequestPayload.h"


@implementation MMCPHTTPRequestPayload

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
            @"requestMethod" : @"method",
    }];
}

#pragma mark -

+ (NSValueTransformer *)requestMethodJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
            MMStringFromRequestMethod(MMRequestMethodGET) : @(MMRequestMethodGET),
            MMStringFromRequestMethod(MMRequestMethodPOST) : @(MMRequestMethodPOST),
            MMStringFromRequestMethod(MMRequestMethodPUT) : @(MMRequestMethodPUT),
            MMStringFromRequestMethod(MMRequestMethodPATCH) : @(MMRequestMethodPATCH),
            MMStringFromRequestMethod(MMRequestMethodDELETE) : @(MMRequestMethodDELETE),
            MMStringFromRequestMethod(MMRequestMethodHEAD) : @(MMRequestMethodHEAD),
            MMStringFromRequestMethod(MMRequestMethodOPTIONS) : @(MMRequestMethodOPTIONS),
    }];
}

@end