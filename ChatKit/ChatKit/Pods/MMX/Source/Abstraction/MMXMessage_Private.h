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

#import "MMXMessage.h"
@class MMXPubSubMessage;

@interface MMXMessage ()


@property(nonatomic, strong, nullable) MMAttachmentProgress *attachmentProgress;

@property (nonatomic, readwrite) MMXMessageType messageType;

@property(nonatomic, readwrite, nullable) NSString *messageID;

@property(nonatomic, readwrite, nullable) NSDate *timestamp;

@property(nonatomic, readwrite, nullable) MMUser *sender;

@property(nonatomic, copy, nullable) NSString *senderDeviceID;

@property (nonatomic, readwrite, nullable) MMXChannel *channel;

@property(nonatomic, readwrite, nullable) NSSet *recipients;

@property(nonatomic, readwrite, nonnull) NSDictionary <NSString *, NSString *> *messageContent;

@property(nonatomic, strong, nullable) NSMutableArray<MMAttachment *> *mutableAttachments;

@property(nonatomic, readwrite, nullable) NSArray<MMAttachment *> *attachments;

@property (nonatomic, nullable) NSString *contentType;

NS_ASSUME_NONNULL_BEGIN
+ (instancetype)messageFromPubSubMessage:(MMXPubSubMessage *)pubSubMessage
								  sender:(MMUser *)sender;
NS_ASSUME_NONNULL_END
@end