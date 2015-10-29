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

#import "MMURLSessionDataTaskOperation.h"
#import <AFNetworking/AFURLSessionManager.h>

@interface MMURLSessionDataTaskOperation ()

- (void)generateKVONotificationForKeyPath:(NSString *)keyPath
                                withBlock:(void (^)())block;

@end

@implementation MMURLSessionDataTaskOperation

- (instancetype)initWithManager:(AFURLSessionManager *)manager
                        request:(NSURLRequest *)request
              completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    if (self = [super init]) {
        _task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (completionHandler) {
                completionHandler(response, responseObject, error);
            }
            [self generateKVONotificationForKeyPath:@"isExecuting" withBlock:nil];
            [self generateKVONotificationForKeyPath:@"isFinished" withBlock:nil];
        }];
    }
    return self;
}

#pragma mark - NSOperation

- (void)cancel {
    [super cancel];
    [self.task cancel];
}

- (void)start {
    if (self.isCancelled) {
        [self generateKVONotificationForKeyPath:@"isFinished" withBlock:nil];
        return;
    }
    [self generateKVONotificationForKeyPath:@"isExecuting" withBlock:^{
        [self.task resume];
    }];
}

- (BOOL)isExecuting {
    return (self.task.state == NSURLSessionTaskStateRunning);
}

- (BOOL)isFinished {
    return (self.task.state == NSURLSessionTaskStateCanceling || self.task.state == NSURLSessionTaskStateCompleted);
}

- (BOOL)isCancelled {
    return (self.task.state == NSURLSessionTaskStateCanceling);
}

- (BOOL)isAsynchronous {
    return YES;
}

#pragma mark - Private implementation

- (void)generateKVONotificationForKeyPath:(NSString *)keyPath
                                withBlock:(void (^)())block {
    [self willChangeValueForKey:keyPath];
    if (block) {
        block();
    }
    [self didChangeValueForKey:keyPath];
}

@end