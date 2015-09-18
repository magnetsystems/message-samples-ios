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
#import "MMXDataModel.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXUserID_Private.h"
#import "MMXMessageOptions.h"

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
	MMXInternalAddress *address = pubSubMessage.senderUserID.address;
	MMXUser *sender = [MMXUser new];
	//Converting to MMXUserID will handle any exscaping needed
	MMXUserID *userID = [MMXUserID userIDFromAddress:address];
	sender.username = userID.username;
	sender.displayName = userID.displayName;
	msg.sender = sender;
	msg.messageID = pubSubMessage.messageID;
	msg.messageContent = pubSubMessage.metaData;
	msg.timestamp = pubSubMessage.timestamp;
	msg.messageType = MMXMessageTypeChannel;
	return msg;
}

- (NSString *)sendWithSuccess:(void (^)(void))success
					  failure:(void (^)(NSError *))failure {
	if (![MMXMessageUtils isValidMetaData:self.messageContent]) {
		NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
		if (failure) {
			failure(error);
		}
		return nil;
	}
	if ([MMXUser currentUser] == nil) {
		NSError * error = [MMXClient errorWithTitle:@"Not Logged In" message:@"You must be logged in to send a message." code:401];
		if (failure) {
			failure(error);
		}
		return nil;
	}
	if (self.channel) {
		NSString *messageID = [[MMXClient sharedClient] generateMessageID];
		MMXPubSubMessage *msg = [MMXPubSubMessage pubSubMessageToTopic:[self.channel asTopic] content:nil metaData:self.messageContent];
		msg.messageID = messageID;
		self.messageID = messageID;
		if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
			if ([MMXUser currentUser]) {
				[self saveForOfflineAsPubSub:msg];
				return messageID;
			} else {
				if (failure) {
					failure([MMXMessage notNotLoggedInAndNoUserError]);
				}
				return nil;
			}
		}
		[[MMXClient sharedClient].pubsubManager publishPubSubMessage:msg success:^(BOOL successful, NSString *messageID) {
			self.sender = [MMXUser currentUser];
			self.timestamp = [NSDate date];
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
		NSString *messageID = [[MMXClient sharedClient] generateMessageID];
		self.messageID = messageID;
		if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
			if ([MMXUser currentUser]) {
				[self saveForOfflineAsInAppMessage];
				return messageID;
			} else {
				if (failure) {
					failure([MMXMessage notNotLoggedInAndNoUserError]);
				}
				return nil;
			}
		}
		[[MagnetDelegate sharedDelegate] sendMessage:self.copy success:^(void) {
			self.sender = [MMXUser currentUser];
			self.timestamp = [NSDate date];
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
	MMXMessage *msg = [MMXMessage messageToRecipients:[NSSet setWithObjects:self.sender, nil] messageContent:content];
	NSString * messageID = [msg sendWithSuccess:^{
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
	NSMutableSet *newSet = [NSMutableSet setWithSet:self.recipients];
	[newSet addObject:self.sender];
	MMXUser *currentUser = [MMXUser currentUser];
	if (currentUser) {
		[newSet removeObject:currentUser];
	}
	MMXMessage *msg = [MMXMessage messageToRecipients:newSet messageContent:content];
	NSString * messageID = [msg sendWithSuccess:^{
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

#pragma mark - Offline

- (void)saveForOfflineAsPubSub:(MMXPubSubMessage *)message {
	[[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:message username:[MMXUser currentUser].username];
}

- (void)saveForOfflineAsInAppMessage {
	MMXInternalMessageAdaptor *message = [MMXInternalMessageAdaptor new];
	message.senderUserID = [MMXUserID userIDFromMMXUser:self.sender];
	message.messageID = self.messageID;
	message.metaData = self.messageContent;
	message.recipients = [self.recipients allObjects];
	
	[[MMXDataModel sharedDataModel] addOutboxEntryWithMessage:message options:[MMXMessageOptions new] username:[MMXUser currentUser].username];
}

#pragma mark - Errors
+ (NSError *)notNotLoggedInAndNoUserError {
	NSError * error = [MMXClient errorWithTitle:@"Forbidden" message:@"You are not logged in and there is no current user." code:403];
	return error;
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

@end
