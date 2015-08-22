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
#import "MMXInternalMessageAdaptor.h"

@class NSXMLElement;
@class XMPPMessage;
@class MMXTopic;
@class XMPPIQ;

@interface MMXInternalMessageAdaptor ()

@property (nonatomic, strong, readwrite) NSString *messageContent;

@property (nonatomic) BOOL deliveryReceiptRequested;

@property (nonatomic, strong, readwrite) NSString*messageID;
@property (nonatomic, strong, readwrite) NSDictionary* metaData;
@property (nonatomic, strong, readwrite) NSDate *timestamp;

@property (nonatomic, strong) NSString* contentType;

@property (nonatomic, strong) NSString* mType;

@property(nonatomic, strong, readwrite) MMXUserID *senderUserID;
@property(nonatomic, strong, readwrite) MMXUserID *targetUserID;
@property(nonatomic, strong, readwrite) MMXEndpoint *senderEndpoint;
@property(nonatomic, readwrite) CLLocation *location;
@property(nonatomic, readwrite) NSArray *recipients;

@property (nonatomic, strong) MMXTopic * topic;

- (instancetype)initWith:(NSArray *)recipients
             withContent:(NSString *)content
             messageType:(NSString *)messageType
                metaData:(NSDictionary *)metaData;

+ (instancetype)initWithXMPPMessage:(XMPPMessage*)xmppMessage;

+ (NSArray *)pubsubMessagesFromFetchResponseIQ:(XMPPIQ *)iq
                                         topic:(MMXTopic *)topic
                                         error:(NSError **)error;

- (NSXMLElement *)contentToXML;
- (NSXMLElement *)metaDataToXML;
+ (NSXMLElement *)xmlFromRecipients:(NSArray *)recipients senderAddress:(MMXInternalAddress *)address;

+ (NSString *)extractPayload:(NSArray *)payLoadElements;
+ (NSDictionary *)extractMetaData:(NSArray *)metaElements;
+ (NSDictionary *)extractMMXMetaData:(NSArray *)metaElements;
+ (MMXUserID *)extractSenderFromMMXMetaDict:(NSDictionary *)mmxMetaDict;
+ (NSArray *)extractRecipientsFromMMXMetaDict:(NSDictionary *)mmxMetaDict;


@end