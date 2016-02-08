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

@class Operation;
@class OperationQueue;
@class AFSecurityPolicy;

@protocol MMRequestOperationManager <NSObject>

@required

/**
 The operation queue on which request operations are scheduled and run.
 */
@property (nonatomic, readonly) OperationQueue *operationQueue;

///-------------------------------
/// @name Managing Security Policy
///-------------------------------

/**
 The security policy used by created request operations to evaluate server trust for secure connections. `AFHTTPRequestOperationManager` uses the `defaultPolicy` unless otherwise specified.
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 Initializes an `MMRequestOperationManager` object with the specified base URL.

 This is the designated initializer.

 @param url The base URL for the HTTP client.

 @return The newly-initialized HTTP client
*/
- (id<MMRequestOperationManager>)initWithBaseURL:(NSURL *)url;

- (Operation *)requestOperationWithRequest:(NSURLRequest *)request
                                     success:(void (^)(NSURLResponse *response, id responseObject))success
                                     failure:(void (^)(NSURLResponse *response, NSError *error))failure;

@end