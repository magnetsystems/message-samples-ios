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

#import "MMXPubSubService.h"
#import "MMXChannel.h"



@implementation MMXPubSubService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method createChannel:success:failure:
        MMServiceMethod *createChannelSuccessFailure = [[MMServiceMethod alloc] init];
        createChannelSuccessFailure.clazz = [self class];
        createChannelSuccessFailure.selector = @selector(createChannel:success:failure:);
        createChannelSuccessFailure.path = @"com.magnet.server/channel/create";
        createChannelSuccessFailure.requestMethod = MMRequestMethodPOST;
        createChannelSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        createChannelSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *createChannelSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *createChannelSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        createChannelSuccessFailureParam0.name = @"body";
        createChannelSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        createChannelSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        createChannelSuccessFailureParam0.typeClass = MMXChannel.class;
        createChannelSuccessFailureParam0.isOptional = NO;
        [createChannelSuccessFailureParams addObject:createChannelSuccessFailureParam0];

        createChannelSuccessFailure.parameters = createChannelSuccessFailureParams;
        createChannelSuccessFailure.returnType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(createChannelSuccessFailure.selector)] = createChannelSuccessFailure;

//        // schema for service method sendChannelMessage:success:failure:
//        MMServiceMethod *sendChannelMessageSuccessFailure = [[MMServiceMethod alloc] init];
//        sendChannelMessageSuccessFailure.clazz = [self class];
//        sendChannelMessageSuccessFailure.selector = @selector(sendChannelMessage:success:failure:);
//        sendChannelMessageSuccessFailure.path = @"com.magnet.server/channel/message/send";
//        sendChannelMessageSuccessFailure.requestMethod = MMRequestMethodPOST;
//        sendChannelMessageSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
//        sendChannelMessageSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
//
//        NSMutableArray *sendChannelMessageSuccessFailureParams = [NSMutableArray array];
//        MMServiceMethodParameter *sendChannelMessageSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
//        sendChannelMessageSuccessFailureParam0.name = @"body";
//        sendChannelMessageSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
//        sendChannelMessageSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
//        sendChannelMessageSuccessFailureParam0.typeClass = MMSendMessageRequest.class;
//        sendChannelMessageSuccessFailureParam0.isOptional = NO;
//        [sendChannelMessageSuccessFailureParams addObject:sendChannelMessageSuccessFailureParam0];
//
//        sendChannelMessageSuccessFailure.parameters = sendChannelMessageSuccessFailureParams;
//        sendChannelMessageSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
//        sendChannelMessageSuccessFailure.returnTypeClass = MMSendMessageResponse.class;
//        serviceMetaData[NSStringFromSelector(sendChannelMessageSuccessFailure.selector)] = sendChannelMessageSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
