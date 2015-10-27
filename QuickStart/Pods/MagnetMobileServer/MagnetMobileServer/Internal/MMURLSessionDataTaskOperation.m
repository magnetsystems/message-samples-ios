/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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