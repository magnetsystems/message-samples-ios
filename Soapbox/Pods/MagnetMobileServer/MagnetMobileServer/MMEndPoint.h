/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface MMEndPoint : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSURL *URL;

+ (instancetype)endPoint;

+ (instancetype)endPointWithURL:(NSURL *)theURL;

+ (instancetype)endPointWithURL:(NSURL *)theURL name:(NSString *)name;

@end
