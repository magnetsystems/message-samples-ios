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


#import "MMXInboundMessage_Private.h"
#import "MMXMessage_Private.h"
#import "MMXUserID_Private.h"
#import "MMXEndpoint_Private.h"

@implementation MMXInboundMessage

+ (instancetype)initWithMessage:(MMXMessage *)message {
	MMXInboundMessage * msg = [[MMXInboundMessage alloc] init];
	msg.messageID		= message.messageID;
	msg.timestamp		= message.timestamp;
	msg.metaData		= message.metaData;
	msg.messageContent	= message.messageContent;
	msg.otherRecipients	= [MMXInboundMessage removeUser:message.targetUserID fromRecipients:message.recipients];
	msg.senderUserID	= message.senderUserID;
	msg.senderEndpoint	= message.senderEndpoint;
	return msg;
}

+ (NSArray *)removeUser:(MMXUserID *)userID fromRecipients:(NSArray *)recipients {
	NSMutableArray *otherRecipients = @[].mutableCopy;
	for (id<MMXAddressable> recipient in recipients) {
		if (![[recipient address] isEqualToString:[userID address]]) {
			[otherRecipients addObject:recipient];
		}
	}
	return otherRecipients.copy;
}
@end
