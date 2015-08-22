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
#import "MMX_Private.h"
#import "MMXChannel.h"
#import "MMXLogInOperation.h"
#import "MMXConnectionOperation.h"
#import "MMXClient_Private.h"
#import "MMXAddressable.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXClient_Private.h"
#import "MMXUserID_Private.h"

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

- (void)startMMXClientWithConfiguration:(NSString *)name {
	//You must include your Configurations.plist file in the project. You can download this file on the Settings page of the Magnet Message Console
	NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"];
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName], @"You must include your Configurations.plist file in the project. You can download this file on the Settings page of the Magnet Message Web Interface");
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated &&
		[MMXClient sharedClient].connectionStatus != MMXConnectionStatusConnected) {
		[MMXClient sharedClient].shouldSuspendIncomingMessages = YES;
		MMXConfiguration * config = [MMXConfiguration configurationWithName:name];
		[MMXClient sharedClient].configuration = config;
		[MMXClient sharedClient].delegate = self;
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
	MMXOutboundMessage *msg = [MMXOutboundMessage messageTo:[message.recipients allObjects] withContent:nil metaData:message.messageContent];
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
	return messageID;
}

- (NSString *)sendInternalMessageFormat:(MMXInternalMessageAdaptor *)message
								success:(void (^)(void))success
								failure:(void (^)(NSError *error))failure {

	NSString *messageID = [[MMXClient sharedClient] sendMMXMessage:message withOptions:nil shouldValidate:NO];
	if (messageID) {
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
	}
	return messageID;
}

#pragma mark - MMXClientDelegate Callbacks

- (void)client:(MMXClient *)client didReceiveConnectionStatusChange:(MMXConnectionStatus)connectionStatus error:(NSError *)error {
	switch (connectionStatus) {
		case MMXConnectionStatusAuthenticated: {
			[[MMXClient sharedClient].accountManager userProfileWithSuccess:^(MMXUserProfile *userProfile) {
				[MMXClient sharedClient].currentProfile = userProfile;
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
			if (error == nil) {
				self.currentUser = nil;
			}
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
			if (error) {
				[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidDisconnectNotification object:nil userInfo:@{MMXDisconnectErrorKey:error}];
			}
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

	MMXMessage *msg = [MMXMessage messageToRecipients:[self usersFromInboundRecipients:message.otherRecipients]
									   messageContent:message.metaData];

	MMXUser *user = [MMXUser new];
	msg.messageType = MMXMessageTypeDefault;
	user.username = message.senderUserID.username;
	user.displayName = message.senderUserID.displayName;
	msg.sender = user;
	msg.timestamp = message.timestamp;
	msg.messageID = message.messageID;
	msg.senderDeviceID = message.senderEndpoint.deviceID;
	[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
														object:nil
													  userInfo:@{MMXMessageKey:msg}];
}

- (void)client:(MMXClient *)client didReceivePubSubMessage:(MMXPubSubMessage *)message {
	MMXMessage *msg = [MMXMessage new];
	msg.messageType = MMXMessageTypeChannel;
	msg.channel = [MMXChannel channelWithName:message.topic.topicName summary:nil];
	msg.messageContent = message.metaData;
	msg.timestamp = message.timestamp;
	msg.messageID = message.messageID;
	MMXUser *user = [MMXUser new];
	user.username = message.senderUserID.username;
	user.displayName = message.senderUserID.displayName;
	msg.sender = user;
	[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveMessageNotification
														object:nil
													  userInfo:@{MMXMessageKey:msg}];
}

- (void)client:(MMXClient *)client didReceiveServerAckForMessageID:(NSString *)messageID recipient:(MMXUserID *)recipient {
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

- (void)client:(MMXClient *)client didDeliverMessage:(NSString *)messageID recipient:(id<MMXAddressable>)recipient {
	MMXUser *user = [MMXUser new];
	MMXInternalAddress *address = recipient.address;
	if (address) {
		user.username = address.username;
		user.displayName = address.displayName;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:MMXDidReceiveDeliveryConfirmationNotification
														object:nil
													  userInfo:@{MMXRecipientKey:user,
																 MMXMessageIDKey:messageID}];
}

+ (NSError *)notNotLoggedInError {
	NSError * error = [MMXClient errorWithTitle:@"Forbidden" message:@"You must log in to use this API." code:403];
	return error;
}

#pragma mark - Recipient conversion

- (NSSet *)usersFromInboundRecipients:(NSArray *)recipients {
	NSMutableSet *set = [NSMutableSet setWithCapacity:recipients.count];
	for (id<MMXAddressable> recipient in recipients) {
		MMXInternalAddress *address = recipient.address;
		MMXUser *user = [MMXUser new];
		user.username = address.username;
		user.displayName = address.displayName;
		[set addObject:user];
	}
	return set.copy;
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
