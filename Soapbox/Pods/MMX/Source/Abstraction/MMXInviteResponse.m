//
//  MMXInviteResponse.m
//  MMX
//
//  Created by Jason Ferguson on 8/20/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXInviteResponse_Private.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXInternalAddress.h"
#import "MMXUser.h"
#import "MMXUserID.h"
#import "MMXInvite_Private.h"

@implementation MMXInviteResponse

+ (instancetype)inviteResponseFromMMXInternalMessage:(MMXInternalMessageAdaptor *)message {
	MMXInviteResponse *response = [MMXInviteResponse new];
	response.textMessage = message.metaData[@"inviteResponseText"];
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
