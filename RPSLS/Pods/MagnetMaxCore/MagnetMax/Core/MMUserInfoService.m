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

#import "MMUserInfoService.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"
#import "MMUser.h"

@implementation MMUserInfoService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method getUserInfoWithSuccess:failure:
        MMServiceMethod *getUserInfoWithSuccessFailure = [[MMServiceMethod alloc] init];
        getUserInfoWithSuccessFailure.path = @"com.magnet.server/userinfo";
        getUserInfoWithSuccessFailure.requestMethod = MMRequestMethodGET;
        getUserInfoWithSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getUserInfoWithSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getUserInfoWithSuccessFailureParams = [NSMutableArray array];
        getUserInfoWithSuccessFailure.parameters = getUserInfoWithSuccessFailureParams;
        getUserInfoWithSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        getUserInfoWithSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(@selector(getUserInfoWithSuccess:failure:))] = getUserInfoWithSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
