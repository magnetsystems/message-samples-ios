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

#import <Foundation/Foundation.h>
#import "MMService.h"

@class MMCall;


@protocol MMConfigurationReaderProtocol <NSObject>

@optional
/**
 
 GET /com.magnet.server/config
 @return A 'MMCall' object.
 */
- (MMCall *)getConfigWithSuccess:(void (^)(NSString *response))success
                         failure:(void (^)(NSError *error))failure;
/**
 
 PUT /com.magnet.server/config/mobile
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)updateMobileConfig:(NSDictionary *)body
                       success:(void (^)(NSDictionary *response))success
                       failure:(void (^)(NSError *error))failure;
/**
 
 GET /com.magnet.server/config/mobile
 @return A 'MMCall' object.
 */
- (MMCall *)getMobileConfigWithSuccess:(void (^)(NSDictionary <NSString *, NSString *>*response))success
                               failure:(void (^)(NSError *error))failure;

@end

@interface MMConfigurationReader : MMService<MMConfigurationReaderProtocol>

@end
