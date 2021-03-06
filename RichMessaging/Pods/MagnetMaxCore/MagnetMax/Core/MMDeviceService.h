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

@class MMDevice;
@class MMCall;

@protocol MMDevicesProtocol <NSObject>

@optional
/**

 GET /api/devices/{deviceId}
 @param deviceId style:PATH
 @param authorization(original name : Authorization) style:HEADER
 @param options
 @return A 'MMCall' object.
 */
- (MMCall *)getDevice:(NSString *)deviceId
        authorization:(NSString *)authorization
              success:(void (^)(MMDevice *response))success
              failure:(void (^)(NSError *error))failure;
/**

 DELETE /api/devices/{deviceId}
 @param deviceId style:PATH
 @param authorization(original name : Authorization) style:HEADER
 @param options
 @return A 'MMCall' object.
 */
- (MMCall *)unRegisterDevice:(NSString *)deviceId
               authorization:(NSString *)authorization
                     success:(void (^)(BOOL response))success
                     failure:(void (^)(NSError *error))failure;
/**

 POST /api/devices
 @param body style:BODY
 @param authorization(original name : Authorization) style:HEADER
 @param options
 @return A 'MMCall' object.
 */
- (MMCall *)registerDevice:(MMDevice *)body
             authorization:(NSString *)authorization
                   success:(void (^)(MMDevice *response))success
                   failure:(void (^)(NSError *error))failure;
/**

 GET /api/devices
 @param skip style:QUERY
 @param take style:QUERY
 @param options
 @return A 'MMCall' object.
 */
- (MMCall *)getDevices:(int)skip
                  take:(int)take
               success:(void (^)(NSArray *response))success
               failure:(void (^)(NSError *error))failure;

@end

@interface MMDeviceService : MMService<MMDevicesProtocol>

@end
