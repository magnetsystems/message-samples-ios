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

#import "MMXServerSettingsService.h"

@implementation MMXServerSettingsService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method updateSettings:success:failure:
        MMServiceMethod *updateSettingsSuccessFailure = [[MMServiceMethod alloc] init];
        updateSettingsSuccessFailure.clazz = [self class];
        updateSettingsSuccessFailure.selector = @selector(updateSettings:success:failure:);
        updateSettingsSuccessFailure.path = @"com.magnet.server/settings/user";
        updateSettingsSuccessFailure.requestMethod = MMRequestMethodPUT;
        updateSettingsSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        updateSettingsSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *updateSettingsSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *updateSettingsSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        updateSettingsSuccessFailureParam0.name = @"body";
        updateSettingsSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        updateSettingsSuccessFailureParam0.type = MMServiceIOTypeDictionary;
        updateSettingsSuccessFailureParam0.componentType = MMServiceIOTypeString;
        updateSettingsSuccessFailureParam0.isOptional = NO;
        [updateSettingsSuccessFailureParams addObject:updateSettingsSuccessFailureParam0];

        updateSettingsSuccessFailure.parameters = updateSettingsSuccessFailureParams;
        updateSettingsSuccessFailure.returnType = MMServiceIOTypeDictionary;
        updateSettingsSuccessFailure.returnComponentType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(updateSettingsSuccessFailure.selector)] = updateSettingsSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
