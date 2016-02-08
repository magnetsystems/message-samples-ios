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

#import "MMConfigurationReader.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"

@implementation MMConfigurationReader

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method getConfigWithSuccess:failure:
        MMServiceMethod *getConfigWithSuccessFailure = [[MMServiceMethod alloc] init];
        getConfigWithSuccessFailure.clazz = [self class];
        getConfigWithSuccessFailure.selector = @selector(getConfigWithSuccess:failure:);
        getConfigWithSuccessFailure.path = @"com.magnet.server/config";
        getConfigWithSuccessFailure.requestMethod = MMRequestMethodGET;
        getConfigWithSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getConfigWithSuccessFailureParams = [NSMutableArray array];
        getConfigWithSuccessFailure.parameters = getConfigWithSuccessFailureParams;
        getConfigWithSuccessFailure.returnType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(getConfigWithSuccessFailure.selector)] = getConfigWithSuccessFailure;

        // schema for service method updateMobileConfig:success:failure:
        MMServiceMethod *updateMobileConfigSuccessFailure = [[MMServiceMethod alloc] init];
        updateMobileConfigSuccessFailure.clazz = [self class];
        updateMobileConfigSuccessFailure.selector = @selector(updateMobileConfig:success:failure:);
        updateMobileConfigSuccessFailure.path = @"com.magnet.server/config/mobile";
        updateMobileConfigSuccessFailure.requestMethod = MMRequestMethodPUT;
        updateMobileConfigSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        updateMobileConfigSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *updateMobileConfigSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *updateMobileConfigSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        updateMobileConfigSuccessFailureParam0.name = @"body";
        updateMobileConfigSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        updateMobileConfigSuccessFailureParam0.type = MMServiceIOTypeDictionary;
        updateMobileConfigSuccessFailureParam0.componentType = MMServiceIOTypeString;
        updateMobileConfigSuccessFailureParam0.isOptional = NO;
        [updateMobileConfigSuccessFailureParams addObject:updateMobileConfigSuccessFailureParam0];

        updateMobileConfigSuccessFailure.parameters = updateMobileConfigSuccessFailureParams;
        updateMobileConfigSuccessFailure.returnType = MMServiceIOTypeDictionary;
        updateMobileConfigSuccessFailure.returnComponentType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(updateMobileConfigSuccessFailure.selector)] = updateMobileConfigSuccessFailure;

        // schema for service method getMobileConfigWithSuccess:failure:
        MMServiceMethod *getMobileConfigWithSuccessFailure = [[MMServiceMethod alloc] init];
        getMobileConfigWithSuccessFailure.clazz = [self class];
        getMobileConfigWithSuccessFailure.selector = @selector(getMobileConfigWithSuccess:failure:);
        getMobileConfigWithSuccessFailure.path = @"com.magnet.server/config/mobile";
        getMobileConfigWithSuccessFailure.requestMethod = MMRequestMethodGET;
        getMobileConfigWithSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getMobileConfigWithSuccessFailureParams = [NSMutableArray array];
        getMobileConfigWithSuccessFailure.parameters = getMobileConfigWithSuccessFailureParams;
        getMobileConfigWithSuccessFailure.returnType = MMServiceIOTypeDictionary;
        getMobileConfigWithSuccessFailure.returnComponentType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(getMobileConfigWithSuccessFailure.selector)] = getMobileConfigWithSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
