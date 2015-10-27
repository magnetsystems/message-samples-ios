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

#import "RPSLSUser.h"
#import "RPSLSConstants.h"
#import "RPSLSUserStats.h"
#import "RPSLSUtils.h"
@import MagnetMobileServer;
@import MMX;

@implementation RPSLSUser

+ (instancetype)userWithUserObject:(MMUser *)userObject stats:(RPSLSUserStats *)stats {
	RPSLSUser * user = [[RPSLSUser alloc] init];
	user.messageUserObject = userObject;
	user.stats = stats;
	return user;
}

+ (instancetype)playerFromInvite:(MMXMessage *)message {
	if (message.messageContent) {
		RPSLSUser * user = [RPSLSUser userWithUserObject:message.sender stats:[RPSLSUserStats statsFromMetaData:message.messageContent]];

		/*
		 *  Extracting info from the MMXInboundMessage metaData to populate the RPSLSUser objects
		 */
		user.timestamp = message.timestamp;
        user.isAvailable = [RPSLSUtils isTrue:message.messageContent[kMessageKey_UserAvailablity]];
		return user;
	}
	return nil;
}

+ (RPSLSUser *)me {
	RPSLSUser * user = [RPSLSUser userWithUserObject:[MMUser currentUser] stats:[RPSLSUserStats myStats]];
	return user;
}

+ (instancetype)availablePlayerFromMessage:(MMXMessage *)message {
	if (message.messageContent) {
		/*
		 *  Extracting info from the MMXInboundMessage metaData to populate the RPSLSUser objects
		 */

		RPSLSUser * user = [RPSLSUser userWithUserObject:message.sender stats:[RPSLSUserStats statsFromMetaData:message.messageContent]];
		user.timestamp = message.timestamp;
		user.isAvailable = [RPSLSUtils isTrue:message.messageContent[kMessageKey_UserAvailablity]];
        return user;
	}
	return nil;
}

+ (NSString *)myUsername {
	/*
	 *  Checking the current username of the logged in user.
	 */
	return [MMUser currentUser].userName;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Username = %@ timestamp = %@",self.messageUserObject.userName, self.timestamp];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)other {
	if (other == self) {
		return YES;
	}
	if (!other || ![[other class] isEqual:[self class]]) {
		return NO;
	}
	return [self isEqualToUser:(RPSLSUser *)other];
}

- (BOOL)isEqualToUser:(RPSLSUser *)user {
	if (!user) {
		return NO;
	}	
	return [self.messageUserObject.userName isEqualToString:user.messageUserObject.userName];
}

- (NSUInteger)hash {
	NSUInteger hash = [self.messageUserObject.userName hash];
	return hash;
}



@end
