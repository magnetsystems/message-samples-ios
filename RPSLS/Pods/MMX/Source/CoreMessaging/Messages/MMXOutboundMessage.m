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


#import "MMXOutboundMessage_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXConstants.h"
#import "MMXMessageUtils.h"
#import "MMXUserID_Private.h"
#import "DDXML.h"
#import "MMXClient_Private.h"
#import "MMXInternalAddress.h"
#import "MMXUserProfile.h"

@implementation MMXOutboundMessage

+ (instancetype)messageTo:(NSArray *)recipients
			  withContent:(NSString *)content
				 metaData:(NSDictionary *)metaData {
    MMXOutboundMessage * msg = [[MMXOutboundMessage alloc] init];
	msg.recipients = recipients;
	msg.messageContent = content;
	msg.metaData = metaData;
	msg.messageID = nil;
    return msg;
}

+ (instancetype)initWithMessage:(MMXInternalMessageAdaptor *)message {
    MMXOutboundMessage * msg = [[MMXOutboundMessage alloc] init];
	if (message.recipients) {
		msg.recipients = message.recipients;
	} else if (message.senderUserID && ![message.senderUserID.username isEqualToString:@""]) {
		msg.recipients = @[message.senderUserID];
	} else {
		msg.recipients = nil;
	}
	msg.messageContent = message.messageContent;
	msg.metaData = message.metaData;
	msg.messageID = (message.messageID && [message.messageID isEqualToString:@""]) ? message.messageID : nil;
    return msg;
}

- (NSXMLElement *)recipientsAndSenderAsXML {
	if (self.recipients == nil || self.recipients.count < 1) {
		return nil;
	}
	NSXMLElement *metaDataElement = [[NSXMLElement alloc] initWithName:@"mmxmeta"];
	
	NSMutableArray *recipientArray = @[].mutableCopy;
	for (id<MMXAddressable> recipient in self.recipients) {
		MMXInternalAddress *address = recipient.address;
		if (address) {
			[recipientArray addObject:[address asDictionary]];
		}
	}
	
	MMXUserProfile *sender = [MMXClient sharedClient].currentProfile;
	MMXInternalAddress *address;
	if (sender) {
		address = sender.address;
	}
	
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"To":recipientArray,
																 @"From":address ? [address asDictionary] : [NSNull null]}
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	NSString *json = [[NSString alloc] initWithData:jsonData
										   encoding:NSUTF8StringEncoding];
	
	[metaDataElement setStringValue:json];
	
	if (error == nil) {
		return metaDataElement;
	}
	return nil;
}

- (NSXMLElement *)contentAsXMLForType:(NSString *)type {
	return [MMXMessageUtils xmlFromContentString:self.messageContent andMessageType:type];
}

- (NSXMLElement *)metaDataAsXML {
	return [MMXMessageUtils xmlFromMetaDataDict:self.metaData];
}

- (NSXMLElement *)asMMXStanza {
	return nil;
}

@end
