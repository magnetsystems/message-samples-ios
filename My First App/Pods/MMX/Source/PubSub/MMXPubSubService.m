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
#import "MMXQueryChannelResponse.h"
#import "MMXQueryChannel.h"
#import "MMXChannel.h"
#import "MMXChannelSummaryRequest.h"
#import "MMXChannelSummaryResponse.h"
#import "MMXChannelResponse.h"
#import "MMXRemoveSubscribersResponse.h"
#import "MMXAddSubscribersResponse.h"

@implementation MMXPubSubService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];
        
        // schema for service method queryChannels:success:failure:
        MMServiceMethod *queryChannelsSuccessFailure = [[MMServiceMethod alloc] init];
        queryChannelsSuccessFailure.clazz = [self class];
        queryChannelsSuccessFailure.selector = @selector(queryChannels:success:failure:);
        queryChannelsSuccessFailure.path = @"com.magnet.server/channel/query";
        queryChannelsSuccessFailure.requestMethod = MMRequestMethodPOST;
        queryChannelsSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        queryChannelsSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *queryChannelsSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *queryChannelsSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        queryChannelsSuccessFailureParam0.name = @"body";
        queryChannelsSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        queryChannelsSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        queryChannelsSuccessFailureParam0.typeClass = MMXQueryChannel.class;
        queryChannelsSuccessFailureParam0.isOptional = NO;
        [queryChannelsSuccessFailureParams addObject:queryChannelsSuccessFailureParam0];
        
        queryChannelsSuccessFailure.parameters = queryChannelsSuccessFailureParams;
        queryChannelsSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        queryChannelsSuccessFailure.returnTypeClass = MMXQueryChannelResponse.class;
        serviceMetaData[NSStringFromSelector(queryChannelsSuccessFailure.selector)] = queryChannelsSuccessFailure;
        
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
        //        sendChannelMessageSuccessFailureParam0.typeClass = MMXSendMessageRequest.class;
        //        sendChannelMessageSuccessFailureParam0.isOptional = NO;
        //        [sendChannelMessageSuccessFailureParams addObject:sendChannelMessageSuccessFailureParam0];
        //
        //        sendChannelMessageSuccessFailure.parameters = sendChannelMessageSuccessFailureParams;
        //        sendChannelMessageSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        //        sendChannelMessageSuccessFailure.returnTypeClass = MMXSendMessageResponse.class;
        //        serviceMetaData[NSStringFromSelector(sendChannelMessageSuccessFailure.selector)] = sendChannelMessageSuccessFailure;
        
        // schema for service method getSummary:success:failure:
        MMServiceMethod *getSummarySuccessFailure = [[MMServiceMethod alloc] init];
        getSummarySuccessFailure.clazz = [self class];
        getSummarySuccessFailure.selector = @selector(getSummary:success:failure:);
        getSummarySuccessFailure.path = @"com.magnet.server/channel/summary";
        getSummarySuccessFailure.requestMethod = MMRequestMethodPOST;
        getSummarySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getSummarySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getSummarySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getSummarySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getSummarySuccessFailureParam0.name = @"body";
        getSummarySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        getSummarySuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        getSummarySuccessFailureParam0.typeClass = MMXChannelSummaryRequest.class;
        getSummarySuccessFailureParam0.isOptional = NO;
        [getSummarySuccessFailureParams addObject:getSummarySuccessFailureParam0];
        
        getSummarySuccessFailure.parameters = getSummarySuccessFailureParams;
        getSummarySuccessFailure.returnType = MMServiceIOTypeArray;
        getSummarySuccessFailure.returnComponentType = MMServiceIOTypeMagnetNode;
        getSummarySuccessFailure.returnTypeClass = MMXChannelSummaryResponse.class;
        serviceMetaData[NSStringFromSelector(getSummarySuccessFailure.selector)] = getSummarySuccessFailure;
        
        // schema for service method addSubscribersToChannel:body:success:failure:
        MMServiceMethod *addSubscribersToChannelBodySuccessFailure = [[MMServiceMethod alloc] init];
        addSubscribersToChannelBodySuccessFailure.clazz = [self class];
        addSubscribersToChannelBodySuccessFailure.selector = @selector(addSubscribersToChannel:body:success:failure:);
        addSubscribersToChannelBodySuccessFailure.path = @"com.magnet.server/channel/{channelName}/subscribers/add";
        addSubscribersToChannelBodySuccessFailure.requestMethod = MMRequestMethodPOST;
        addSubscribersToChannelBodySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        addSubscribersToChannelBodySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *addSubscribersToChannelBodySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *addSubscribersToChannelBodySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        addSubscribersToChannelBodySuccessFailureParam0.name = @"channelName";
        addSubscribersToChannelBodySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        addSubscribersToChannelBodySuccessFailureParam0.type = MMServiceIOTypeString;
        addSubscribersToChannelBodySuccessFailureParam0.isOptional = NO;
        [addSubscribersToChannelBodySuccessFailureParams addObject:addSubscribersToChannelBodySuccessFailureParam0];
        
        MMServiceMethodParameter *addSubscribersToChannelBodySuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        addSubscribersToChannelBodySuccessFailureParam1.name = @"body";
        addSubscribersToChannelBodySuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeBody;
        addSubscribersToChannelBodySuccessFailureParam1.type = MMServiceIOTypeMagnetNode;
        addSubscribersToChannelBodySuccessFailureParam1.typeClass = MMXChannel.class;
        addSubscribersToChannelBodySuccessFailureParam1.isOptional = NO;
        [addSubscribersToChannelBodySuccessFailureParams addObject:addSubscribersToChannelBodySuccessFailureParam1];
        
        addSubscribersToChannelBodySuccessFailure.parameters = addSubscribersToChannelBodySuccessFailureParams;
        addSubscribersToChannelBodySuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        addSubscribersToChannelBodySuccessFailure.returnTypeClass = MMXAddSubscribersResponse.class;
        serviceMetaData[NSStringFromSelector(addSubscribersToChannelBodySuccessFailure.selector)] = addSubscribersToChannelBodySuccessFailure;
        
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
        createChannelSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        createChannelSuccessFailure.returnTypeClass = MMXChannelResponse.class;
        serviceMetaData[NSStringFromSelector(createChannelSuccessFailure.selector)] = createChannelSuccessFailure;
        
        // schema for service method removeSubscribersFromChannel:body:success:failure:
        MMServiceMethod *removeSubscribersFromChannelBodySuccessFailure = [[MMServiceMethod alloc] init];
        removeSubscribersFromChannelBodySuccessFailure.clazz = [self class];
        removeSubscribersFromChannelBodySuccessFailure.selector = @selector(removeSubscribersFromChannel:body:success:failure:);
        removeSubscribersFromChannelBodySuccessFailure.path = @"com.magnet.server/channel/{channelName}/subscribers/remove";
        removeSubscribersFromChannelBodySuccessFailure.requestMethod = MMRequestMethodPOST;
        removeSubscribersFromChannelBodySuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        removeSubscribersFromChannelBodySuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *removeSubscribersFromChannelBodySuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *removeSubscribersFromChannelBodySuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        removeSubscribersFromChannelBodySuccessFailureParam0.name = @"channelName";
        removeSubscribersFromChannelBodySuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypePath;
        removeSubscribersFromChannelBodySuccessFailureParam0.type = MMServiceIOTypeString;
        removeSubscribersFromChannelBodySuccessFailureParam0.isOptional = NO;
        [removeSubscribersFromChannelBodySuccessFailureParams addObject:removeSubscribersFromChannelBodySuccessFailureParam0];
        
        MMServiceMethodParameter *removeSubscribersFromChannelBodySuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        removeSubscribersFromChannelBodySuccessFailureParam1.name = @"body";
        removeSubscribersFromChannelBodySuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeBody;
        removeSubscribersFromChannelBodySuccessFailureParam1.type = MMServiceIOTypeMagnetNode;
        removeSubscribersFromChannelBodySuccessFailureParam1.typeClass = MMXChannel.class;
        removeSubscribersFromChannelBodySuccessFailureParam1.isOptional = NO;
        [removeSubscribersFromChannelBodySuccessFailureParams addObject:removeSubscribersFromChannelBodySuccessFailureParam1];
        
        removeSubscribersFromChannelBodySuccessFailure.parameters = removeSubscribersFromChannelBodySuccessFailureParams;
        removeSubscribersFromChannelBodySuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        removeSubscribersFromChannelBodySuccessFailure.returnTypeClass = MMXRemoveSubscribersResponse.class;
        serviceMetaData[NSStringFromSelector(removeSubscribersFromChannelBodySuccessFailure.selector)] = removeSubscribersFromChannelBodySuccessFailure;
        
        
        __metaData = serviceMetaData;
    });
    
    return __metaData;
}

@end
