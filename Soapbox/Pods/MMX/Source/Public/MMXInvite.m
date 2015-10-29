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
#import "MMXTopic_Private.h"
#import "MMXUserID_Private.h"
#import "MagnetDelegate.h"
#import "MMXUtils.h"
@import MagnetMaxCore;

@implementation MMXInvite


- (void)acceptWithComments:(NSString *)comments
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure {
	MMXInternalMessageAdaptor *msg = [MMXInternalMessageAdaptor inviteResponseMessageToUser:self.sender forChannel:self.channel comments:comments response:YES];
	[[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^(NSSet *invalidUsers){
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
	[[MagnetDelegate sharedDelegate] sendInternalMessageFormat:msg success:^(NSSet *invalidUsers){
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
	invite.channel = [MMXInvite channelFromMessageMetaData:message.metaData];
	invite.timestamp = message.timestamp;
	return invite;
}

+ (MMXChannel *)channelFromMessageMetaData:(NSDictionary *)metaData {
	if (metaData) {
		NSString *summary = [MMXUtils objectIsValidString:metaData[@"channelSummary"]] ? metaData[@"channelSummary"] : @"";
		MMXChannel *channel = [MMXChannel channelWithName:metaData[@"channelName"]
												  summary:summary
												 isPublic:[metaData[@"channelIsPublic"] boolValue]
									   publishPermissions:[MMXTopic publishPermissionsFromString:metaData[@"channelPublishPermissions"]]];
		if ([MMXUtils objectIsValidString:metaData[@"channelCreationDate"]]) {
			NSDate *channelCreationDate = [MMXUtils dateFromiso8601Format:metaData[@"channelCreationDate"]];
			channel.creationDate = channelCreationDate;
		}
		NSString * ownerUserID = [MMXUtils objectIsValidString:metaData[@"channelCreatorUsername"]] ? metaData[@"channelCreatorUsername"] : @"";
		channel.ownerUserID = ownerUserID;
		return channel;
	}
	return nil;
}

@end
