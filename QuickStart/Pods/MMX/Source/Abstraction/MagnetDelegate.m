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

#import "MagnetDelegate.h"
#import "MMXMessage_Private.h"
#import "MagnetConstants.h"
#import "MMXUser.h"
#import "MMXMessageTypes.h"
#import "MMX.h"
#import "MMXChannel.h"
#import "MMXLogInOperation.h"
#import "MMXConnectionOperation.h"

typedef void(^MessageSuccessBlock)(void);
typedef void(^MessageFailureBlock)(NSError *);

NSString  * const MMXMessageSuccessBlockKey = @"MMXMessageSuccessBlockKey";
NSString  * const MMXMessageFailureBlockKey = @"MMXMessageFailureBlockKey";

@interface MagnetDelegate () <MMXClientDelegate>

@property (nonatomic, copy) void (^connectSuccessBlock)(void);

@property (nonatomic, copy) void (^connectFailureBlock)(NSError *);

@property (nonatomic, copy) void (^logInSuccessBlock)(MMXUser *);

@property (nonatomic, copy) void (^logInFailureBlock)(NSError *);

@property (nonatomic, copy) void (^logOutSuccessBlock)(void);

@property (nonatomic, copy) void (^logOutFailureBlock)(NSError *);

@property (nonatomic, strong) NSMutableDictionary *messageBlockQueue;

@property(nonatomic, strong) NSOperationQueue *internalQueue;

@end

@implementation MagnetDelegate

+ (instancetype)sharedDelegate {
	
	static MagnetDelegate *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedClient = [[MagnetDelegate alloc] init];
		_sharedClient.messageBlockQueue = [NSMutableDictionary dictionary];
	});
	return _sharedClient;
}

- (void)startMMXClient {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated &&
		[MMXClient sharedClient].connectionStatus != MMXConnectionStatusConnected) {
		MMXConfiguration * config = [MMXConfiguration configurationWithName:@"default"];
		[MMXClient sharedClient].configuration = config;
		[MMXClient sharedClient].delegate = self;
		[self connect];
	}
}

- (void)connect {
	MMXConnectionOperation *op = [MMXConnectionOperation new];
	[self.internalQueue addOperation:op];
}

- (void)registerUser:(MMXUser *)user
		 credentials:(NSURLCredential *)credential
			 success:(void (^)(void))success
			 failure:(void (^)(NSError *))failure {
	[[MMXClient sharedClient].accountManager createAccountForUsername:user.username displayName:user.displayName email:user.email password:credential.password success:^(MMXUserProfile *userProfile) {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

- (void)connectWithSuccess:(void (^)(void))success
				   failure:(void (^)(NSError *error))failure {
	
	self.connectSuccessBlock = success;
	self.connectFailureBlock = failure;
	[[MMXClient sharedClient] connectAnonymous];
	
}


- (void)logInWithCredential:(NSURLCredential *)credential
					success:(void (^)(MMXUser *))success
					failure:(void (^)(NSError *error))failure {

	MMXLogInOperation *op = [MMXLogInOperation new];
	op.creds = credential.copy;
	op.logInSuccessBlock = success;
	op.logInFailureBlock = failure;
	[self.internalQueue addOperation:op];

}

- (void)privateLogInWithCredential:(NSURLCredential *)credential
						   success:(void (^)(MMXUser *))success
						   failure:(void (^)(NSError *error))failure {
	
	[MMXClient sharedClient].configuration.credential = credential;
	self.logInSuccessBlock = success;
	self.logInFailureBlock = failure;
	[[MMXClient sharedClient] connectWithCredentials];
}


- (void)logOutWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError *error))failure {
	self.logOutSuccessBlock = success;
	self.logOutFailureBlock = failure;
	[[MMXClient sharedClient] disconnect];
}

- (NSString *)sendMessage:(MMXMessage *)message
				  success:(void (^)(void))success
				  failure:(void (^)(NSError *error))failure {
	//FIXME: Needs to properly handle failure and success blocks
	MMXOutboundMessage *msg = [MMXOutboundMessage messageTo:[message recipientsForOutboundMessage] withContent:nil metaData:message.messageContent];
	NSString *messageID = [[MMXClient sharedClient] sendMessage:msg];
	
	if (success || failure) {
		NSMutableDictionary *blockDict = [NSMutableDictionary dictionary];
		if (success) {
			[blockDict setObject:success forKey:MMXMessageSuccessBlockKey];
		}
		if (failure) {
			[blockDict setObject:failure forKey:MMXMessageFailureBlockKey];
		}
		[self.messageBlockQueue setObject:blockDict forKey:messageID];
	}
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSDictionary *blockDict = [self.messageBlockQueue objectForKey:messageID];
		if (blockDict) {
			MessageSuccessBlock successBlock = [blockDict objectForKey:MMXMessageSuccessBlockKey];
			if (successBlock) {
				successBlock();
			}
			[self.messageBlockQueue removeObjectForKey:messageID];
		}
	});
	
	return messageID;
}

#pragma mark - MMXClientDelegate Callbacks

- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	switch (connectionStatus) {
		case MMXConnectionStatusAuthenticated: {
			[[MMXClient sharedClient].accountManager userProfileWithSuccess:^(MMXUserProfile *userProfile) {
				MMXUser *user = [MMXUser new];
				user.username = userProfile.userID.username;
				user.displayName = userProfile.displayName;
				user.email = userProfile.email;
				self.currentUser = user.copy;
				if (self.logInSuccessBlock) {
					self.logInSuccessBlock(user);
					self.logInSuccessBlock = nil;
					self.logInFailureBlock = nil;
				}
			} failure:^(NSError *error) {
				if (self.logInSuccessBlock) {
					self.logInSuccessBlock(nil);
					self.logInSuccessBlock = nil;
					self.logInFailureBlock = nil;
				}
			}];
			}
			break;
		case MMXConnectionStatusAuthenticationFailure: {
			if (self.logInFailureBlock) {
				self.logInFailureBlock(error);
			}
			self.logInSuccessBlock = nil;
			self.logInFailureBlock = nil;
			}
			break;
		case MMXConnectionStatusNotConnected: {
			}
			break;
		case MMXConnectionStatusConnected: {
			if (self.connectSuccessBlock) {
				self.connectSuccessBlock();
			}
			self.connectSuccessBlock = nil;
			self.connectFailureBlock = nil;
			}
			break;
		case MMXConnectionStatusDisconnected: {
			self.currentUser = nil;
			if (self.logOutSuccessBlock) {
				self.logOutSuccessBlock();
			}
			if (self.connectFailureBlock) {
				self.connectFailureBlock(error);
			}
			self.connectSuccessBlock = nil;
			self.connectFailureBlock = nil;
			self.logOutSuccessBlock = nil;
			self.logOutFailureBlock = nil;
		}
			break;
		case MMXConnectionStatusFailed: {
			if (self.connectFailureBlock) {
				self.connectFailureBlock(error);
			}
			if (self.logInFailureBlock) {
				self.logInFailureBlock(error);
			}
			self.connectSuccessBlock = nil;
			self.connectFailureBlock = nil;
			self.logInSuccessBlock = nil;
			self.logInFailureBlock = nil;

			}
			break;
		case MMXConnectionStatusReconnecting: {
			}
			break;
	}
}



- (void)client:(MMXClient *)client didReceiveMessage:(MMXInboundMessage *)message deliveryReceiptRequested:(BOOL)receiptRequested {
	//FIXME: remove the receiver/current user from the list of recipients.
	MMXMessage *msg = [MMXMessage messageToRecipients:[NSSet setWithArray:message.otherRecipients]
							 messageContent:message.metaData];
	MMXUser *user = [MMXUser new];
	msg.messageType = MMXMessageTypeDefault;
	user.username = message.senderUserID.username;
	msg.sender = user;
	msg.timestamp = message.timestamp;
	msg.messageID = message.messageID;
	[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
														object:nil
													  userInfo:@{MagnetMessageKey:msg}];
}

- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message {
	MMXMessage *msg = [MMXMessage new];
	msg.messageType = MMXMessageTypeChannel;
	msg.channel = [MMXChannel channelWithName:message.topic.topicName summary:nil];
	msg.messageContent = message.metaData;
	msg.timestamp = message.timestamp;
	msg.messageID = message.messageID;
	[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
														object:nil
													  userInfo:@{MagnetMessageKey:msg}];
}

- (void)client:(MMXClient *)client didReceiveMessageSentSuccessfully:(NSString *)messageID {
	NSDictionary *messageBlockDict = [self.messageBlockQueue objectForKey:messageID];
	if (messageBlockDict) {
		MessageSuccessBlock success = messageBlockDict[MMXMessageSuccessBlockKey];
		if (success) {
			success();
		}
		[self.messageBlockQueue removeObjectForKey:messageID];
	}
}

- (void)client:(MMXClient *)client didFailToSendMessage:(NSString *)messageID recipients:(NSArray *)recipients error:(NSError *)error {
	NSDictionary *messageBlockDict = [self.messageBlockQueue objectForKey:messageID];
	if (messageBlockDict) {
		MessageFailureBlock failure = messageBlockDict[MMXMessageFailureBlockKey];
		if (failure) {
			failure(error);
		}
		[self.messageBlockQueue removeObjectForKey:messageID];
	}
}

#pragma mark - Overriden getters

- (NSOperationQueue *)internalQueue {
	
	if (!_internalQueue) {
		_internalQueue = [[NSOperationQueue alloc] init];
		_internalQueue.maxConcurrentOperationCount = 1;
	}
	
	return _internalQueue;
}

@end
