/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
@import Mantle;


@interface MMCPHTTPPayload : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy) NSDictionary *headers;

@property(nonatomic, strong) id body;

@end