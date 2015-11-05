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
#import "MMXInternal_Private.h"
#import "MMXMessageUtils.h"
#import "MMXClient_Private.h"
#import "MMXChannel_Private.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXDataModel.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXUserID_Private.h"
#import "MMXMessageOptions.h"
#import "MMXTopic_Private.h"
#import "MMXInternalAddress.h"
#import "MMXConstants.h"
#import "MMUser+Addressable.h"

@import MagnetMaxCore;

@implementation MMXMessage

+ (instancetype)messageToRecipients:(NSSet <MMUser *>*)recipients
					 messageContent:(NSDictionary <NSString *,NSString *>*)messageContent {
	MMXMessage *msg = [MMXMessage new];
	msg.recipients = recipients;
	msg.messageContent = messageContent;
	return msg;
};

+ (instancetype)messageToChannel:(MMXChannel *)channel
				  messageContent:(NSDictionary <NSString *,NSString *>*)messageContent {
	MMXMessage *msg = [MMXMessage new];
	msg.channel = channel;
	msg.messageContent = messageContent;
	return msg;
}

+ (instancetype)messageFromPubSubMessage:(MMXPubSubMessage *)pubSubMessage
								  sender:(MMUser *)sender {
	MMXMessage *msg = [MMXMessage new];
	msg.channel = [MMXChannel channelWithName:pubSubMessage.topic.topicName summary:pubSubMessage.topic.topicDescription isPublic:pubSubMessage.topic.inUserNameSpace publishPermissions:pubSubMessage.topic.publishPermissions];
	if (pubSubMessage.topic.inUserNameSpace) {
		msg.channel.isPublic = NO;
		msg.channel.ownerUserID = pubSubMessage.topic.nameSpace;
	} else {
		msg.channel.isPublic = YES;
	}
	msg.sender = sender;
	msg.messageID = pubSubMessage.messageID;
	msg.messageContent = pubSubMessage.metaData;
	msg.timestamp = pubSubMessage.timestamp;
	msg.messageType = MMXMessageTypeChannel;
	return msg;
}

- (NSString *)sendWithSuccess:(void (^)(NSSet <NSString *>*invalidUsers))success
					  failure:(void (^)(NSError *))failure {
	if (![MMXMessageUtils isValidMetaData:self.messageContent]) {
		NSError * error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
		if (failure) {
			failure(error);
		}
		return nil;
	}
	if ([MMUser currentUser] == nil) {
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
			if ([MMUser currentUser]) {
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
			self.sender = [MMUser currentUser];
			self.timestamp = [NSDate date];
			if (success) {
				success([NSSet set]);
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
			if ([MMUser currentUser]) {
				[self saveForOfflineAsInAppMessage];
				return messageID;
			} else {
				if (failure) {
					failure([MMXMessage notNotLoggedInAndNoUserError]);
				}
				return nil;
			}
		}
		NSError *error;
		[MMXMessage validateMessageRecipients:self.recipients content:self.messageContent error:&error];
		if (error) {
			if (failure) {
				failure(error);
			}
		} else {
			[[MagnetDelegate sharedDelegate] sendMessage:self.copy success:^(NSSet *invalidUsers) {
				self.sender = [MMUser currentUser];
				self.timestamp = [NSDate date];
				if (self.recipients.count == invalidUsers.count) {
					if (failure) {
						NSError *error = [MMXClient errorWithTitle:@"Invalid User(s)" message:@"The user(s) you are trying to send a message to does not exist or does not have a valid device associated with them." code:500];
						failure(error);
					}
				} else {
					if (success) {
						success(invalidUsers);
					}
				}
			} failure:^(NSError *error) {
				if (failure) {
					failure(error);
				}
			}];
		}
		return messageID;
	}
}

- (NSString *)replyWithContent:(NSDictionary <NSString *,NSString *>*)content
					   success:(void (^)(NSSet <NSString *>*invalidUsers))success
					   failure:(void (^)(NSError *))failure {
	NSSet *recipients = [NSSet setWithObject:self.sender];
	NSError *error;
	[MMXMessage validateMessageRecipients:recipients content:self.messageContent error:&error];
	if (error) {
		if (failure) {
			failure(error);
		}
		return nil;
	}
	
	MMXMessage *msg = [MMXMessage messageToRecipients:recipients messageContent:content];
	NSString * messageID = [msg sendWithSuccess:^(NSSet *invalidUsers) {
		if (success) {
			success(invalidUsers);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
	return messageID;
}

- (NSString *)replyAllWithContent:(NSDictionary <NSString *,NSString *>*)content
						  success:(void (^)(NSSet <NSString *>*invalidUsers))success
						  failure:(void (^)(NSError *))failure {
	NSMutableSet *newSet = [NSMutableSet setWithSet:self.recipients];
	[newSet addObject:self.sender];
	MMUser *currentUser = [MMUser currentUser];
	if (currentUser) {
		[newSet removeObject:currentUser];
	}
	NSError *error;
	[MMXMessage validateMessageRecipients:newSet content:self.messageContent error:&error];
	if (error) {
		if (failure) {
			failure(error);
		}
		return nil;
	}
	MMXMessage *msg = [MMXMessage messageToRecipients:newSet messageContent:content];
	NSString * messageID = [msg sendWithSuccess:^(NSSet *invalidUsers) {
		if (success) {
			success(invalidUsers);
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
	[[MMXDataModel sharedDataModel] addOutboxEntryWithPubSubMessage:message username:[MMUser currentUser].userName];
}

- (void)saveForOfflineAsInAppMessage {
	MMXInternalMessageAdaptor *message = [MMXInternalMessageAdaptor new];
	message.senderUserID = [MMXUserID userIDFromMMUser:self.sender];
	message.messageID = self.messageID;
	message.metaData = self.messageContent;
	message.recipients = [self.recipients allObjects];
	
	[[MMXDataModel sharedDataModel] addOutboxEntryWithMessage:message options:[MMXMessageOptions new] username:[MMUser currentUser].userName];
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

+ (BOOL)validateMessageRecipients:(NSSet *)recipients content:(NSDictionary *)content error:(NSError **)error {
	if (recipients == nil || recipients.count < 1) {
		*error = [MMXClient errorWithTitle:@"Recipients not set" message:@"Recipients cannot be nil" code:401];
		return NO;
	} else {
		for (MMUser *user in recipients) {
			if (user.userID == nil || [user.userID isEqualToString:@""]) {
				*error = [MMXClient errorWithTitle:@"Invalid Recipients" message:@"One or more recipients are not valid because their userID is nil" code:401];
				return NO;
			}
		}

	}
	
	if (![MMXMessageUtils isValidMetaData:content]) {
		*error = [MMXClient errorWithTitle:@"Not Valid" message:@"All values must be strings." code:401];
		return NO;
	}
	if ([MMXMessageUtils sizeOfMessageContent:nil metaData:content] > kMaxMessageSize) {
		*error = [MMXClient errorWithTitle:@"Message too large" message:@"Message content exceeds the max size of 200KB" code:401];
		return NO;
	}
	return YES;
}

@end
