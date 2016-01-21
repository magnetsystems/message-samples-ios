/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
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
