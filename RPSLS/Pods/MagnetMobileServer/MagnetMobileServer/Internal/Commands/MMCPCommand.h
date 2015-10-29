/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
@import Mantle;
#import "MMCPPriority.h"

@class MMCPHTTPPayload;

/*
 MMCPCommand is an abstract superclass defining an API for other commands.
 It should not be instantiated directly. All subclasses should minimally override - (NSString *)name;
 */
@interface MMCPCommand : MTLModel <MTLJSONSerializing>

@property(nonatomic, readonly) NSString *name;

@property(nonatomic, copy) NSString *commandId;

@property(nonatomic, assign) MMCPPriority priority;

@property(nonatomic, strong) MMCPHTTPPayload *payload;

@end