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

#import "XMPPIQ.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXConstants.h"
#import "MMXPubSubManager.h"
#import "MMXClient.h"
#import "MMXAccountManager_Private.h"
#import "MMXTopic_Private.h"
#import "MMXUtils.h"
#import "MMXMessageUtils.h"
#import "MMXUserProfile_Private.h"
#import "XMPPFramework.h"

//messageType = @"TEXTMSG"
@implementation MMXPubSubMessage

+ (instancetype)initWithMessage:(MMXInternalMessageAdaptor *)message {
    MMXPubSubMessage * msg = [[MMXPubSubMessage alloc] init];
	msg.messageID = message.messageID;
	msg.messageContent = message.messageContent;
	msg.topic = message.topic;
	msg.metaData = message.metaData;
	msg.timestamp = message.timestamp;
	msg.senderUserID = message.senderUserID;
    return msg;
}

+ (instancetype)pubSubMessageToTopic:(MMXTopic *)topic content:(NSString *)content metaData:(NSDictionary *)metaData {
	MMXPubSubMessage * msg = [[MMXPubSubMessage alloc] init];
    msg.topic = topic;
	msg.metaData = metaData;
	msg.messageContent = content;
    return msg;
}

+ (NSArray *)pubSubMessagesFromXMPPMessage:(XMPPMessage *)xmppMessage {
	NSMutableArray * messageArray = @[].mutableCopy;
	
	NSXMLElement *eventElement = [xmppMessage elementForName:@"event"];
	NSXMLElement *itemsElement = [eventElement elementForName:@"items"];
	MMXTopic *topic = [self topicFromXMPPMessage:xmppMessage];
	for (NSXMLElement *itemElement in [itemsElement elementsForName:@"item"]) {
		MMXPubSubMessage *msg = [[MMXPubSubMessage alloc] init];
		msg.messageID = [[itemElement attributeForName:@"id"] stringValue];
		NSXMLElement *mmxElement = [itemElement elementForName:MXmmxElement xmlns:MXnsDataPayload];
		
		//payload
		NSArray* payLoadElements = [mmxElement elementsForName:MXpayloadElement];
		msg.messageContent = [MMXMessageUtils extractPayload:payLoadElements];
		NSXMLNode* timestamp = [[mmxElement elementForName:MXpayloadElement] attributeForName:@"stamp"];
		if ([timestamp stringValue] && ![[timestamp stringValue] isEqualToString:@""]) {
			msg.timestamp = [MMXUtils dateFromiso8601Format:[timestamp stringValue]];
		}
		//meta
		NSArray* metaElements = [mmxElement elementsForName:MXmetaElement];
		msg.metaData = [MMXMessageUtils extractMetaData:metaElements];
		msg.topic = topic.copy;
		
		NSArray* mmxMetaElements = [mmxElement elementsForName:MXmmxMetaElement];
		if (mmxMetaElements) {
			NSDictionary *mmxMetaDict = [MMXInternalMessageAdaptor extractMMXMetaData:mmxMetaElements];
			MMXUserID *senderID = [MMXInternalMessageAdaptor extractSenderFromMMXMetaDict:mmxMetaDict];
			if (senderID) {
				msg.senderUserID = senderID;
			}
		}
		[messageArray addObject:msg];
	}
	return messageArray.copy;
}

- (MMXInternalMessageAdaptor *)asMMXMessage {
	MMXInternalMessageAdaptor * message = [[MMXInternalMessageAdaptor alloc] init];
	message.messageID = self.messageID;
	message.messageContent = self.messageContent;
	message.topic = self.topic;
	message.metaData = self.metaData;
	message.timestamp = self.timestamp;
	return message;
}

+ (MMXTopic *)topicFromXMPPMessage:(XMPPMessage *)xmppMessage {
	NSXMLElement *eventElement = [xmppMessage elementForName:@"event"];
	NSXMLElement *itemsElement = [eventElement elementForName:@"items"];
	NSXMLNode* node = [itemsElement attributeForName:@"node"];
	MMXTopic * topic = [MMXTopic topicFromNode:[node stringValue]];
	//Topic
	return topic;
}

- (XMPPIQ *)pubsubIQForAppID:(NSString *)appID
                  currentJID:(XMPPJID *)currentJID
					  itemID:(NSString *)itemID {
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsDataPayload];
    NSXMLElement *payload = [MMXUtils contentToXML:self.messageContent type:@"TEXTMSG"];
    [mmxElement addChild:payload];
    if (self.metaData) {
        NSXMLElement *meta = [MMXUtils metaDataToXML:self.metaData];
        [mmxElement addChild:meta];
    }
	
	MMXUserProfile *sender = [MMXClient sharedClient].currentProfile;
	if (sender && sender.address) {
		NSXMLElement *mmxMeta = [MMXInternalMessageAdaptor xmlFromRecipients:nil senderAddress:sender.address];
		[mmxElement addChild:mmxMeta];
	}
	
    NSXMLElement *itemElement = [[NSXMLElement alloc] initWithName:@"item"];
    [itemElement addAttributeWithName:@"id" stringValue:itemID];
    [itemElement addChild:mmxElement];
    NSXMLElement *publishElement = [[NSXMLElement alloc] initWithName:@"publish"];
    NSString * nameSpace = @"*";
    if (self.topic.inUserNameSpace) {
        nameSpace = self.topic.nameSpace;
    }
    NSString *fullTopicName = [NSString stringWithFormat:@"/%@/%@/%@", appID, nameSpace, [self.topic.topicName lowercaseString]];
    [publishElement addAttributeWithName:@"node" stringValue:fullTopicName];
    [publishElement addChild:itemElement];
    NSXMLElement *pubsubElement = [[NSXMLElement alloc] initWithName:@"pubsub" xmlns:@"http://jabber.org/protocol/pubsub"];
    [pubsubElement addChild:publishElement];

    XMPPIQ *postIQ = [[XMPPIQ alloc] initWithType:@"set" child:pubsubElement];
    [postIQ addAttributeWithName:@"from" stringValue: [currentJID full]];
    [postIQ addAttributeWithName:@"id" stringValue:self.messageID];

    [postIQ addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"pubsub.%@",[currentJID domain]]];
    return postIQ;
}

@end
