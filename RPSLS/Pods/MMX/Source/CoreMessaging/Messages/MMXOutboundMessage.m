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
#import "MMXMessage_Private.h"
#import "MMXConstants.h"
#import "MMXMessageUtils.h"
#import "MMXUserID_Private.h"
#import "DDXML.h"

@implementation MMXOutboundMessage

+ (instancetype)messageTo:(id<MMXAddressable>)recipient withContent:(NSString *)content metaData:(NSDictionary *)metaData {
    MMXOutboundMessage * msg = [[MMXOutboundMessage alloc] init];
	msg.recipient = recipient;
	msg.messageContent = content;
	msg.metaData = metaData;
	msg.messageID = nil;
    return msg;
}

+ (instancetype)initWithMessage:(MMXMessage *)message {
    MMXOutboundMessage * msg = [[MMXOutboundMessage alloc] init];
	if (message.recipient) {
		msg.recipient = message.recipient;
	} else if (message.receiverUsername) {
		msg.recipient = [MMXUserID userIDWithUsername:message.receiverUsername];
	} else {
		msg.recipient = nil;
	}
	msg.messageContent = message.messageContent;
	msg.metaData = message.metaData;
	msg.messageID = (message.messageID && [message.messageID isEqualToString:@""]) ? message.messageID : nil;
    return msg;
}

- (NSXMLElement *)contentAsXMLForType:(NSString *)type {
	return [MMXMessageUtils xmlFromContentString:self.messageContent andMessageType:type];
}

- (NSXMLElement *)metaDataAsXML {
	return [MMXMessageUtils xmlFromMetaDataDict:self.metaData];
}

@end
