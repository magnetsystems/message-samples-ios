/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMRequestOperationManager.h"

@class AFHTTPSessionManager;


@interface MMHTTPRequestOperationManager : NSObject <MMRequestOperationManager>

@property(nonatomic, strong) AFHTTPSessionManager *manager;

@end