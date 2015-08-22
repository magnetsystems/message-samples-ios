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

#import "MMXInviteResponse_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXUser.h"
#import "MMXUserID.h"
#import "MMXInvite_Private.h"

@implementation MMXInviteResponse

+ (instancetype)inviteResponseFromMMXInternalMessage:(MMXInternalMessageAdaptor *)message {
	MMXInviteResponse *response = [MMXInviteResponse new];
	response.comments = message.metaData[@"inviteResponseText"];
	MMXInternalAddress *address = message.senderUserID.address;
	MMXUser *user = [MMXUser new];
	user.username = address.username;
	user.displayName = address.displayName;
	response.sender = user;
	response.channel = [MMXInvite channelFromMessageMetaData:message.metaData];
	response.timestamp = message.timestamp;
	response.accepted = [message.metaData[@"inviteIsAccepted"] boolValue];
	return response;
}

@end
