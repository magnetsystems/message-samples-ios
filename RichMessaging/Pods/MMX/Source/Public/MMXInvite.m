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
#import "MMXUserID_Private.h"
#import "MMXUser.h"
#import "MagnetDelegate.h"

@implementation MMXInvite


- (void)acceptWithComments:(NSString *)comments
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure {
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteResponseMessageToUser:self.sender forChannel:self.channel comments:comments response:YES];
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

- (void)declineWithComments:(NSString *)comments
                    success:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteResponseMessageToUser:self.sender forChannel:self.channel comments:comments response:NO];
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
	invite.comments = message.metaData[@"text"];
	MMXInternalAddress *address = message.senderUserID.address;
	MMXUser *user = [MMXUser new];
	//Converting to MMXUserID will handle any exscaping needed
	MMXUserID *userID = [MMXUserID userIDFromAddress:address];
	user.username = userID.username;
	user.displayName = userID.displayName;
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
