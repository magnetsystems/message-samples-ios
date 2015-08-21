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

#import "MMXInvite_Private.h"
#import "MMXInternalMessageAdaptor.h"
#import "MMXChannel_Private.h"
#import "MMXUserID.h"
#import "MMXUser.h"
#import "MagnetDelegate.h"

@implementation MMXInvite


- (void)acceptWithMessage:(NSString *)textMessage
				  success:(void (^)(void))success
				  failure:(void (^)(NSError *))failure {
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteResponseMessageToUser:self.sender forChannel:self.channel textMessage:textMessage response:YES];
	[[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^{
	} failure:^(NSError *error) {
	}];
	[self.channel subscribeWithSuccess:^{
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

- (void)declineWithMessage:(NSString *)textMessage
				   success:(void (^)(void))success
				   failure:(void (^)(NSError *))failure {
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteResponseMessageToUser:self.sender forChannel:self.channel textMessage:textMessage response:NO];
	[[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^{
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (instancetype)inviteFromMMXInternalMessage:(MMXInternalMessageAdaptor *)message {
	MMXInvite *invite = [MMXInvite new];
	invite.textMessage = message.metaData[@"text"];
	MMXInternalAddress *address = message.senderUserID.address;
	MMXUser *user = [MMXUser new];
	user.username = address.username;
	user.displayName = address.displayName;
	invite.sender = user;
	invite.channel = [MMXInvite channelFromMessageMetaData:message.metaData];
	invite.timestamp = message.timestamp;
	return invite;
}

+ (MMXChannel *)channelFromMessageMetaData:(NSDictionary *)metaData {
	if (metaData) {
		MMXChannel *channel = [MMXChannel channelWithName:metaData[@"channelName"] summary:metaData[@"channelSummary"]];
		channel.isPublic = ![metaData[@"channelIsPublic"] boolValue];
		channel.ownerUsername = metaData[@"channelCreatorUsername"];
		return channel;
	}
	return nil;
}

/*
 msg.metaData = @{@"text":textMessage ?: [NSNull null],
 @"channelIsPrivate":@(!channel.isPublic),
 @"channelName":channel.name,
 @"channelSummary":channel.summary ?: [NSNull null],
 @"channelCreatorUsername":channel.ownerUsername ?: [NSNull null]};

 */
@end
