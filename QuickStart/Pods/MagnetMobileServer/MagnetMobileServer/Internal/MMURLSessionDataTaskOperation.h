/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AFURLSessionManager;


@interface MMURLSessionDataTaskOperation : NSOperation

@property (nonatomic, readonly) NSURLSessionDataTask *task;

- (instancetype)initWithManager:(AFURLSessionManager *)manager
                        request:(NSURLRequest *)request
              completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end