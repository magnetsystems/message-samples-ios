/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class MMServiceAdapter;
@class MMServiceMethod;


@interface MMRestHandler : NSObject

+ (NSURLRequest *)requestWithInvocation:(NSInvocation *)anInvocation
                          serviceMethod:(MMServiceMethod *)method
                         serviceAdapter:(MMServiceAdapter *)adapter
                                useMock:(BOOL)useMock
                               useCache:(BOOL)useCache
                               cacheAge:(NSTimeInterval)cacheAge;

@end