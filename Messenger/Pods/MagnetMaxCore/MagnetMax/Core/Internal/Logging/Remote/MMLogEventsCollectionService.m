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

#import "MMLogEventsCollectionService.h"
#import "MMLogEvent.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"
#import "MMCall.h"

@implementation MMLogEventsCollectionService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method addEventsFromFile:success:failure:
        MMServiceMethod *addEventsFromFileSuccessFailure = [[MMServiceMethod alloc] init];
        addEventsFromFileSuccessFailure.path = @"com.magnet.server/collections/events/batch";
        addEventsFromFileSuccessFailure.requestMethod = MMRequestMethodPOST;
        addEventsFromFileSuccessFailure.consumes = [NSSet setWithObjects:@"multipart/form-data", nil];

        NSMutableArray *addEventsFromFileSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *addEventsFromFileSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        addEventsFromFileSuccessFailureParam0.name = @"file";
        addEventsFromFileSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeFormData;
        addEventsFromFileSuccessFailureParam0.type = MMServiceIOTypeData;
        addEventsFromFileSuccessFailureParam0.isOptional = NO;
        [addEventsFromFileSuccessFailureParams addObject:addEventsFromFileSuccessFailureParam0];

        addEventsFromFileSuccessFailure.parameters = addEventsFromFileSuccessFailureParams;
        addEventsFromFileSuccessFailure.returnType = MMServiceIOTypeVoid;
        serviceMetaData[NSStringFromSelector(@selector(addEventsFromFile:success:failure:))] = addEventsFromFileSuccessFailure;

        // schema for service method addEvents:success:failure:
        MMServiceMethod *addEventsSuccessFailure = [[MMServiceMethod alloc] init];
        addEventsSuccessFailure.path = @"com.magnet.server/collections/events";
        addEventsSuccessFailure.requestMethod = MMRequestMethodPOST;
        addEventsSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        addEventsSuccessFailure.produces = [NSSet setWithObjects:@"text/plain", nil];

        NSMutableArray *addEventsSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *addEventsSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        addEventsSuccessFailureParam0.name = @"body";
        addEventsSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        addEventsSuccessFailureParam0.type = MMServiceIOTypeArray;
        addEventsSuccessFailureParam0.componentType = MMServiceIOTypeMagnetNode;
        addEventsSuccessFailureParam0.typeClass = MMLogEvent.class;
        addEventsSuccessFailureParam0.isOptional = NO;
        [addEventsSuccessFailureParams addObject:addEventsSuccessFailureParam0];

        addEventsSuccessFailure.parameters = addEventsSuccessFailureParams;
        addEventsSuccessFailure.returnType = MMServiceIOTypeBoolean;
        serviceMetaData[NSStringFromSelector(@selector(addEvents:success:failure:))] = addEventsSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
