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

#import "MMDeviceService.h"
#import "MMDevice.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"

@implementation MMDeviceService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method getDevice:authorization:success:failure:
        MMServiceMethod *getDeviceAuthorizationSuccessFailure = [[MMServiceMethod alloc] init];
        getDeviceAuthorizationSuccessFailure.path = @"com.magnet.server/devices/{deviceId}";
        getDeviceAuthorizationSuccessFailure.requestMethod = MMRequestMethodGET;
        getDeviceAuthorizationSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getDeviceAuthorizationSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getDeviceAuthorizationSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getDeviceAuthorizationSuccessFailureParam0.name = @"deviceId";
        getDeviceAuthorizationSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        getDeviceAuthorizationSuccessFailureParam0.type = MMServiceIOTypeString;
        getDeviceAuthorizationSuccessFailureParam0.isOptional = NO;
        [getDeviceAuthorizationSuccessFailureParams addObject:getDeviceAuthorizationSuccessFailureParam0];

        MMServiceMethodParameter *getDeviceAuthorizationSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        getDeviceAuthorizationSuccessFailureParam1.name = @"Authorization";
        getDeviceAuthorizationSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeHeader;
        getDeviceAuthorizationSuccessFailureParam1.type = MMServiceIOTypeString;
        getDeviceAuthorizationSuccessFailureParam1.isOptional = NO;
        [getDeviceAuthorizationSuccessFailureParams addObject:getDeviceAuthorizationSuccessFailureParam1];

        getDeviceAuthorizationSuccessFailure.parameters = getDeviceAuthorizationSuccessFailureParams;
        getDeviceAuthorizationSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        getDeviceAuthorizationSuccessFailure.returnTypeClass = MMDevice.class;
        serviceMetaData[NSStringFromSelector(@selector(getDevice:authorization:success:failure:))] = getDeviceAuthorizationSuccessFailure;

        // schema for service method unRegisterDevice:authorization:success:failure:
        MMServiceMethod *unRegisterDeviceAuthorizationSuccessFailure = [[MMServiceMethod alloc] init];
        unRegisterDeviceAuthorizationSuccessFailure.path = @"com.magnet.server/devices/{deviceId}";
        unRegisterDeviceAuthorizationSuccessFailure.requestMethod = MMRequestMethodDELETE;
        unRegisterDeviceAuthorizationSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *unRegisterDeviceAuthorizationSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *unRegisterDeviceAuthorizationSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        unRegisterDeviceAuthorizationSuccessFailureParam0.name = @"deviceId";
        unRegisterDeviceAuthorizationSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        unRegisterDeviceAuthorizationSuccessFailureParam0.type = MMServiceIOTypeString;
        unRegisterDeviceAuthorizationSuccessFailureParam0.isOptional = NO;
        [unRegisterDeviceAuthorizationSuccessFailureParams addObject:unRegisterDeviceAuthorizationSuccessFailureParam0];

        MMServiceMethodParameter *unRegisterDeviceAuthorizationSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        unRegisterDeviceAuthorizationSuccessFailureParam1.name = @"Authorization";
        unRegisterDeviceAuthorizationSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeHeader;
        unRegisterDeviceAuthorizationSuccessFailureParam1.type = MMServiceIOTypeString;
        unRegisterDeviceAuthorizationSuccessFailureParam1.isOptional = NO;
        [unRegisterDeviceAuthorizationSuccessFailureParams addObject:unRegisterDeviceAuthorizationSuccessFailureParam1];

        unRegisterDeviceAuthorizationSuccessFailure.parameters = unRegisterDeviceAuthorizationSuccessFailureParams;
        unRegisterDeviceAuthorizationSuccessFailure.returnType = MMServiceIOTypeBoolean;
        serviceMetaData[NSStringFromSelector(@selector(unRegisterDevice:authorization:success:failure:))] = unRegisterDeviceAuthorizationSuccessFailure;

        // schema for service method registerDevice:authorization:success:failure:
        MMServiceMethod *registerDeviceAuthorizationSuccessFailure = [[MMServiceMethod alloc] init];
        registerDeviceAuthorizationSuccessFailure.path = @"com.magnet.server/devices";
        registerDeviceAuthorizationSuccessFailure.requestMethod = MMRequestMethodPOST;
        registerDeviceAuthorizationSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *registerDeviceAuthorizationSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *registerDeviceAuthorizationSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        registerDeviceAuthorizationSuccessFailureParam0.name = @"body";
        registerDeviceAuthorizationSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        registerDeviceAuthorizationSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        registerDeviceAuthorizationSuccessFailureParam0.typeClass = MMDevice.class;
        registerDeviceAuthorizationSuccessFailureParam0.isOptional = NO;
        [registerDeviceAuthorizationSuccessFailureParams addObject:registerDeviceAuthorizationSuccessFailureParam0];

        MMServiceMethodParameter *registerDeviceAuthorizationSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        registerDeviceAuthorizationSuccessFailureParam1.name = @"Authorization";
        registerDeviceAuthorizationSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeHeader;
        registerDeviceAuthorizationSuccessFailureParam1.type = MMServiceIOTypeString;
        registerDeviceAuthorizationSuccessFailureParam1.isOptional = YES;
        [registerDeviceAuthorizationSuccessFailureParams addObject:registerDeviceAuthorizationSuccessFailureParam1];

        registerDeviceAuthorizationSuccessFailure.parameters = registerDeviceAuthorizationSuccessFailureParams;
        registerDeviceAuthorizationSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        registerDeviceAuthorizationSuccessFailure.returnTypeClass = MMDevice.class;
        serviceMetaData[NSStringFromSelector(@selector(registerDevice:authorization:success:failure:))] = registerDeviceAuthorizationSuccessFailure;

        // schema for service method getDevices:take:success:failure:
        MMServiceMethod *getDevicesTakeSuccessFailure = [[MMServiceMethod alloc] init];
        getDevicesTakeSuccessFailure.path = @"com.magnet.server/devices";
        getDevicesTakeSuccessFailure.requestMethod = MMRequestMethodGET;
        getDevicesTakeSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getDevicesTakeSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getDevicesTakeSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getDevicesTakeSuccessFailureParam0.name = @"skip";
        getDevicesTakeSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeQuery;
        getDevicesTakeSuccessFailureParam0.type = MMServiceIOTypeInteger;
        getDevicesTakeSuccessFailureParam0.isOptional = NO;
        [getDevicesTakeSuccessFailureParams addObject:getDevicesTakeSuccessFailureParam0];

        MMServiceMethodParameter *getDevicesTakeSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        getDevicesTakeSuccessFailureParam1.name = @"take";
        getDevicesTakeSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeQuery;
        getDevicesTakeSuccessFailureParam1.type = MMServiceIOTypeInteger;
        getDevicesTakeSuccessFailureParam1.isOptional = NO;
        [getDevicesTakeSuccessFailureParams addObject:getDevicesTakeSuccessFailureParam1];

        getDevicesTakeSuccessFailure.parameters = getDevicesTakeSuccessFailureParams;
        getDevicesTakeSuccessFailure.returnType = MMServiceIOTypeArray;
        getDevicesTakeSuccessFailure.returnComponentType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(@selector(getDevices:take:success:failure:))] = getDevicesTakeSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
