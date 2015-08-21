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

#import "MMXPubSubMessage.h"
@class MMXInternalMessageAdaptor;
@class XMPPIQ;
@class XMPPMessage;

@interface MMXPubSubMessage ()

@property (nonatomic, readwrite) NSString *messageID;
@property (nonatomic, readwrite) NSDictionary *metaData;
@property (nonatomic, readwrite) NSString *messageContent;
@property (nonatomic, readwrite) NSDate *timestamp;
@property (nonatomic, readwrite) MMXTopic * topic;
@property (nonatomic, readwrite) MMXUserID *senderUserID;

+ (instancetype)initWithMessage:(MMXInternalMessageAdaptor *)message;
+ (NSArray *)pubSubMessagesFromXMPPMessage:(XMPPMessage *)xmppMessage;
- (MMXInternalMessageAdaptor *)asMMXMessage;

- (XMPPIQ *)pubsubIQForAppID:(NSString *)appID
				  currentJID:(XMPPJID *)currentJID
					  itemID:(NSString *)itemID;

@end