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
@import MagnetMaxCore;
@class MMXQueryChannelResponse;
@class MMXQueryChannel;
@class MMXChannelSummaryRequest;
@class MMXChannelResponse;
@class MMXAddSubscribersResponse;
@class MMXRemoveSubscribersResponse;
@class MMXChannel;
@class MMXMuteChannelPushRequest;

@protocol MMXPubSubServiceProtocol <NSObject>

@optional
/**
 
 POST /com.magnet.server/channel/query
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)queryChannels:(MMXQueryChannel *)body
                  success:(void (^)(MMXQueryChannelResponse *response))success
                  failure:(void (^)(NSError *error))failure;
///**
// 
// POST /com.magnet.server/channel/message/send
// @param body style:BODY
// @return A 'MMCall' object.
// */
//- (MMCall *)sendChannelMessage:(MMXSendMessageRequest *)body
//                       success:(void (^)(MMXSendMessageResponse *response))success
//                       failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/channel/summary
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)getSummary:(MMXChannelSummaryRequest *)body
               success:(void (^)(NSArray *response))success
               failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/channel/{channelName}/subscribers/add
 @param channelName style:PATH
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)addSubscribersToChannel:(NSString *)channelName
                               body:(MMXChannel *)body
                            success:(void (^)(MMXAddSubscribersResponse *response))success
                            failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/channel/create
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)createChannel:(MMXChannel *)body
                  success:(void (^)(MMXChannelResponse *response))success
                  failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/channel/{channelName}/subscribers/remove
 @param channelName style:PATH
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)removeSubscribersFromChannel:(NSString *)channelName
                                    body:(MMXChannel *)body
                                 success:(void (^)(MMXRemoveSubscribersResponse *response))success
                                 failure:(void (^)(NSError *error))failure;

/**
 
 POST /com.magnet.server/channel/{channelId}/push/mute
 @param channelId style:PATH
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)muteChannelPush:(NSString *)channelId
                       body:(MMXMuteChannelPushRequest *)body
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;

/**
 
 POST /com.magnet.server/channel/{channelId}/push/unmute
 @param channelId style:PATH
 @return A 'MMCall' object.
 */
- (MMCall *)unmuteChannelPush:(NSString *)channelId
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure;


@end

@interface MMXPubSubService : MMService<MMXPubSubServiceProtocol>

@end
