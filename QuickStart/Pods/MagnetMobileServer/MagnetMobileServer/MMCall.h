/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMAsynchronousOperation.h"


@class MMCacheOptions;

@class MMReliableCallOptions;

@interface MMCall : MMAsynchronousOperation

/**
 * Should the mock implementation be used?
 */
@property(nonatomic, assign) BOOL useMock;

/**
 * A system-generated unique ID for this call.
 */
@property(nonatomic, readonly) NSString *callId;

- (void)executeInBackground:(MMCacheOptions *)cacheOptions;

- (void)executeEventually:(MMReliableCallOptions *)reliableCallOptions;

@end
