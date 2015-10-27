/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMService.h"

@class MMCall;
@class MMUser;


@protocol MMUserInfoServiceProtocol <NSObject>

@optional
/**
 
 GET /api/com.magnet.server/userinfo
 @return A 'MMCall' object.
 */
- (MMCall *)getUserInfoWithSuccess:(void (^)(MMUser *response))success
                           failure:(void (^)(NSError *error))failure;

@end

@interface MMUserInfoService : MMService<MMUserInfoServiceProtocol>

@end
