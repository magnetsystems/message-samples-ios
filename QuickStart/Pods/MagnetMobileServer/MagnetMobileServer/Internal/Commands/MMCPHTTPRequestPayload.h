/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMHTTPUtilities.h"
#import "MMCPHTTPPayload.h"


@interface MMCPHTTPRequestPayload : MMCPHTTPPayload

@property(nonatomic, copy) NSString *path;

@property(nonatomic, assign) MMRequestMethod requestMethod;

@end