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

#import "MMHTTPRequestOperationManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>


@interface MMHTTPRequestOperationManager ()

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, readwrite) OperationQueue *operationQueue;

@end

@implementation MMHTTPRequestOperationManager

@synthesize securityPolicy = _securityPolicy;

- (id<MMRequestOperationManager>)initWithBaseURL:(NSURL *)theURL {
    self = [super init];
    if (self) {
        self.URL = theURL;
    }

    return self;
}

- (NSOperation *)requestOperationWithRequest:(NSURLRequest *)request
                                     success:(void (^)(NSURLResponse *response, id responseObject))success
                                     failure:(void (^)(NSURLResponse *response, NSError *error))failure {
    
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *responseError) {
        if (responseError) {
            if (failure) {
                failure(response, responseError);
            }
        } else {
            if (success) {
                success(response, responseObject);
            }
        }
    }];
    URLSessionTaskOperation *operation = [[URLSessionTaskOperation alloc] initWithTask:task];
    
    return operation;
}

#pragma mark - Overriden getters

- (OperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[OperationQueue alloc] init];
    }
    
    return _operationQueue;
}

@end