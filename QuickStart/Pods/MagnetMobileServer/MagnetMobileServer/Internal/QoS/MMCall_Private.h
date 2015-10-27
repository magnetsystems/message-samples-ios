/**
 * Copyright (c) 2012-2014 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCall.h"

@class MMServiceMethod;

@interface MMCall ()

@property (nonatomic, strong) NSInvocation *invocation;

@property (nonatomic, strong) MMServiceMethod *serviceMethod;

@property (nonatomic, strong) MMServiceAdapter *serviceAdapter;

@property(nonatomic, strong) NSOperation *underlyingOperation;

@property(nonatomic, readwrite) NSString *callId;

@property(nonatomic, strong) MMCacheOptions *cacheOptions;

@property(nonatomic, strong) MMReliableCallOptions *reliableCallOptions;


@end
