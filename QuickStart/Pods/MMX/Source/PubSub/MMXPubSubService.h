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

@class MMXChannel;

@protocol MMXPubSubServiceProtocol <NSObject>

@optional
/**
 
 POST /com.magnet.server/channel/create
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)createChannel:(MMXChannel *)body
                  success:(void (^)(NSString *response))success
                  failure:(void (^)(NSError *error))failure;
/**
 
 POST /com.magnet.server/channel/message/send
 @param body style:BODY
 @return A 'MMCall' object.
 */
//- (MMCall *)sendChannelMessage:(MMSendMessageRequest *)body
//                       success:(void (^)(MMSendMessageResponse *response))success
//                       failure:(void (^)(NSError *error))failure;

@end

@interface MMXPubSubService : MMService<MMXPubSubServiceProtocol>

@end
