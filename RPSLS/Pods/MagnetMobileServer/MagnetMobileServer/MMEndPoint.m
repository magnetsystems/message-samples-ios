/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMEndPoint.h"

static NSString *const MMDefaultName = @"MMDefaultName";

@implementation MMEndPoint

+ (instancetype)endPoint {
    MMEndPoint *endPoint = [[self alloc] init];
    endPoint.name = MMDefaultName;

    return endPoint;
}

+ (instancetype)endPointWithURL:(NSURL *)theURL {
    MMEndPoint *endPoint = [MMEndPoint endPoint];
    endPoint.URL = theURL;

    return endPoint;
}

+ (instancetype)endPointWithURL:(NSURL *)theURL name:(NSString *)name {
    MMEndPoint *endPoint = [MMEndPoint endPoint];
    endPoint.name = name;
    endPoint.URL = theURL;

    return endPoint;
}


@end