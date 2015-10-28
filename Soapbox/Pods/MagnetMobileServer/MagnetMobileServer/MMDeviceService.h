/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
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
