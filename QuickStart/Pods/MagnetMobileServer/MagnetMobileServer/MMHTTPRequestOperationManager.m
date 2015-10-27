/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMHTTPRequestOperationManager.h"
#import "MMURLSessionDataTaskOperation.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>


@interface MMHTTPRequestOperationManager ()

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, readwrite) OperationQueue *operationQueue;

@property(nonatomic, readwrite) OperationQueue *reliableOperationQueue;

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
                                     failure:(void (^)(NSError *error))failure {

    MMURLSessionDataTaskOperation *operation = [[MMURLSessionDataTaskOperation alloc] initWithManager:self.manager
                                                                                              request:request
                                                                                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *responseError) {
        if (responseError) {
            if (failure) {
                failure(responseError);
            }
        } else {
            if (success) {
                success(response, responseObject);
            }
        }
    }];

    return operation;
}

#pragma mark - Overriden getters

- (OperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[OperationQueue alloc] init];
    }
    
    return _operationQueue;
}

- (OperationQueue *)reliableOperationQueue {
    if (!_reliableOperationQueue) {
        _reliableOperationQueue = [[OperationQueue alloc] init];
    }
    
    return _reliableOperationQueue;
}

@end