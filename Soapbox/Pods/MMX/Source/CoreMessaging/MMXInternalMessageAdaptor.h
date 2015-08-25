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
#import "MMXAddressable.h"
#import <Mantle/Mantle.h>

@class CLLocation;
@class MMXUserID;
@class MMXEndpoint;
@class MMXTopic;
@class MMXUser;
@class MMXChannel;

@interface MMXInternalMessageAdaptor : MTLModel

//All Messages
@property(nonatomic, strong, readonly) NSString *messageID;
@property(nonatomic, strong, readonly) NSDictionary *metaData;
@property(nonatomic, strong, readonly) NSString *messageContent;

//Inbound Messages
@property(nonatomic, strong, readonly) MMXUserID *senderUserID;
@property(nonatomic, strong, readonly) NSString *senderDisplayName;
@property(nonatomic, strong, readonly) MMXEndpoint *senderEndpoint;
@property(nonatomic, strong, readonly) MMXUserID *targetUserID;
@property(nonatomic, strong, readonly) NSString *targetDisplayName;
@property(nonatomic, strong, readonly) NSDate *timestamp;

//Outbound Messages
@property(nonatomic, readonly) NSArray *recipients;

//PubSub
@property(nonatomic, strong, readonly) MMXTopic *topic;

//GeoLocation Message
@property(nonatomic, copy, readonly) CLLocation *location;

+ (instancetype)messageTo:(NSArray *)recipients
              withContent:(NSString *)content
              messageType:(NSString *)messageType
                 metaData:(NSDictionary *)metaData;

+ (instancetype)inviteMessageToUser:(MMXUser *)recipient
						 forChannel:(MMXChannel *)channel
						   comments:(NSString *)comments;

+ (instancetype)inviteResponseMessageToUser:(MMXUser *)recipient
								 forChannel:(MMXChannel *)channel
								   comments:(NSString *)comments
								   response:(BOOL)response;
@end
