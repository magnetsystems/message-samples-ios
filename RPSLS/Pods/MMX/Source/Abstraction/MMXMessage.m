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

#import "MMXMessage_Private.h"
#import "MagnetDelegate.h"
#import "MMXUser.h"
#import "MMXChannel.h"
#import "MMX_Private.h"
#import "MMXMessageUtils.h"
#import "MMXClient_Private.h"
#import "MMXChannel_Private.h"
#import "MMXPubSubMessage_Private.h"

@implementation MMXMessage

+ (instancetype)messageToRecipients:(NSSet *)recipients
					 messageContent:(NSDictionary *)messageContent {
	MMXMessage *msg = [MMXMessage new];
	msg.recipients = recipients;
	msg.messageContent = messageContent;
	return msg;
};

+ (instancetype)messageToChannel:(MMXChannel *)channel
				  messageContent:(NSDictionary *)messageContent {
	MMXMessage *msg = [MMXMessage new];
	msg.channel = channel;
	msg.messageContent = messageContent;
	return msg;
}

+ (instancetype)messageFromPubSubMessage:(MMXPubSubMessage *)pubSubMessage {
	MMXMessage *msg = [MMXMessage new];
	msg.channel = [MMXChannel channelWithName:pubSubMessage.topic.topicName summary:pubSubMessage.topic.topicDescription];
	msg.messageContent = pubSubMessage.metaData;
	return msg;
}

- (NSString *)sendWithSuccess:(void (^)(void))success
					  failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
	//FIXME: Make sure that the content is JSON serializable
	if (![MMXMessageUtils isValidMetaData:self.messageContent]) {
		NSError * error = [MMXClient errorWithTitle:@"Message Content Not Valid" message:@"Message Content dictionary must be JSON serializable." code:401];
		if (failure) {
			failure(error);
		}
		return nil;
	}
	if (self.channel) {
		NSString *messageID = [[MMXClient sharedClient] generateMessageID];
		self.messageID = messageID;
		MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self.channel asTopic] content:nil metaData:self.messageContent];
		msg.messageID = messageID;
		[[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
			if (success) {
				success();
			}
		} failure:^(NSError *error) {
			if (failure) {
				failure(error);
			}
		}];
		return messageID;
	} else {
		NSString * messageID = [[MagnetDelegate sharedDelegate] sendMessage:self.copy success:^(void) {
			if (success) {
				success();
			}
		} failure:^(NSError *error) {
			if (failure) {
				failure(error);
			}
		}];
		return messageID;
	}
}

- (NSString *)replyWithContent:(NSDictionary *)content
				 success:(void (^)(void))success
				 failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
	MMXMessage *msg = [MMXMessage messageToRecipients:[NSSet setWithObjects:self.sender, nil] messageContent:content];
	NSString * messageID = [[MagnetDelegate sharedDelegate] sendMessage:msg success:^() {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
	return messageID;
}

- (NSString *)replyAllWithContent:(NSDictionary *)content
					success:(void (^)(void))success
					failure:(void (^)(NSError *))failure {
	//FIXME: Handle case that user is not logged in
	NSMutableSet *newSet = [NSMutableSet setWithSet:self.recipients];
	[newSet addObject:self.sender];
	MMXMessage *msg = [MMXMessage messageToRecipients:newSet messageContent:content];
	NSString * messageID = [[MagnetDelegate sharedDelegate] sendMessage:msg success:^() {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
	return messageID;
}

#pragma mark - Helpers
- (NSArray *)replyAllArray {
	NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:self.recipients.count + 1];
	[recipients addObject:self.sender];
	[recipients addObjectsFromArray:[self.recipients allObjects]];
	return recipients.copy;
}

- (void)sendDeliveryConfirmation {
	[[MMXClient sharedClient] sendDeliveryConfirmationForAddress:self.sender.address messageID:self.messageID toDeviceID:self.senderDeviceID];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_messageID = [coder decodeObjectForKey:@"_messageID"];
		_timestamp = [coder decodeObjectForKey:@"_timestamp"];
		_sender = [coder decodeObjectForKey:@"_sender"];
		_channel = [coder decodeObjectForKey:@"_channel"];
		_recipients = [coder decodeObjectForKey:@"_recipients"];
		_messageContent = [coder decodeObjectForKey:@"_messageContent"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.messageID forKey:@"_messageID"];
	[coder encodeObject:self.timestamp forKey:@"_timestamp"];
	[coder encodeObject:self.sender forKey:@"_sender"];
	[coder encodeObject:self.channel forKey:@"_channel"];
	[coder encodeObject:self.recipients forKey:@"_recipients"];
	[coder encodeObject:self.messageContent forKey:@"_messageContent"];
}

- (id)copyWithZone:(NSZone *)zone {
	MMXMessage *copy = [[[self class] allocWithZone:zone] init];
	
	if (copy != nil) {
		copy.messageID = self.messageID;
		copy.timestamp = self.timestamp;
		copy.sender = self.sender;
		copy.channel = self.channel;
		copy.recipients = self.recipients;
		copy.messageContent = self.messageContent;
	}
	
	return copy;
}

@end
