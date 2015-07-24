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
#import <MMX/MMX.h>

@implementation RPSLSUser

+ (instancetype)userWithUsername:(NSString *)username stats:(RPSLSUserStats *)stats {
	RPSLSUser * user = [[RPSLSUser alloc] init];
	user.username = username;
	user.stats = stats;
	return user;
}

+ (instancetype)playerFromInvite:(MMXInboundMessage *)message {
	if (message.metaData) {
		RPSLSUser * user = [[RPSLSUser alloc] init];

		/*
		 *  Extracting info from the MMXInboundMessage metaData to populate the RPSLSUser objects
		 */
		user.username = message.metaData[kMessageKey_Username] ?: @"Unknown";
		user.timestamp = message.timestamp;
		user.stats = [RPSLSUserStats statsFromMetaData:message.metaData];
		user.isAvailable = [message.metaData[kMessageKey_UserAvailablity] isEqualToString:kPostStatus_Available] ? YES : NO;
		return user;
	}
	return nil;
}

+ (RPSLSUser *)me {
	RPSLSUser * user = [[RPSLSUser alloc] init];
	user.username = [self myUsername];
	user.stats = [RPSLSUserStats myStats];
	return user;
}

+ (instancetype)availablePlayerFromPubSubMessage:(MMXPubSubMessage *)message {
	if (message.metaData) {
		RPSLSUser * user = [[RPSLSUser alloc] init];
		
		/*
		 *  Extracting info from the MMXInboundMessage metaData to populate the RPSLSUser objects
		 */
		user.username = message.metaData[kMessageKey_Username] ?: @"Unknown";
		user.timestamp = message.timestamp;
		user.stats = [RPSLSUserStats statsFromMetaData:message.metaData];
		user.isAvailable = [message.metaData[kMessageKey_UserAvailablity] boolValue];
		return user;
	}
	return nil;
}

+ (NSString *)myUsername {
	/*
	 *  Checking the current username of the logged in user.
	 */
	return [MMXClient sharedClient].configuration.credential.user;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Username = %@ timestamp = %@",self.username, self.timestamp];
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
	return [self.username isEqualToString:user.username];
}

- (NSUInteger)hash {
	NSUInteger hash = [self.username hash];
	return hash;
}



@end
