/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMCPHTTPPayload.h"


@interface MMCPHTTPResponsePayload : MMCPHTTPPayload

@property(nonatomic, assign) int status;

@property(nonatomic, copy) NSString *reason;

@end