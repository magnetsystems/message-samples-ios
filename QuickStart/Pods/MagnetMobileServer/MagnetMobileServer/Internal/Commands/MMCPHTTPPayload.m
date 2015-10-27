/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPHTTPPayload.h"
#import "MMCPHTTPRequestPayload.h"
#import "MMCPHTTPResponsePayload.h"


@implementation MMCPHTTPPayload

#pragma mark - MTLJSONSerializing methods

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"headers" : @"headers",
             @"body" : @"body",
    };
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {

    if (JSONDictionary[@"path"] != nil && JSONDictionary[@"method"] != nil) {
        return MMCPHTTPRequestPayload.class;
    }

    if (JSONDictionary[@"status"] != nil && JSONDictionary[@"reason"] != nil) {
        return MMCPHTTPResponsePayload.class;
    }

    NSAssert(NO, @"No matching class for the JSON dictionary '%@'.", JSONDictionary);
    return self;
}

@end