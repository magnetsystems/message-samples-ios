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

#import "MMXUserID_Private.h"
#import "NSString+XEP_0106.h"
#import "MMXUser.h"

@implementation MMXUserID

+ (instancetype)userIDWithUsername:(NSString *)username {
	MMXUserID * userID = [[MMXUserID alloc] init];
	userID.username = username;
	return userID;
}

+ (instancetype)userIDFromMMXUser:(MMXUser *)user {
	MMXUserID * userID = [[MMXUserID alloc] init];
	userID.username = user.username;
	userID.displayName = user.displayName;
	return userID;
}

+ (instancetype)userIDFromAddress:(MMXInternalAddress *)address {
	MMXUserID * userID = [[MMXUserID alloc] init];
	if (address.username && ![address.username isEqualToString:@""]) {
		userID.username = [address.username jidUnescapedString];
		userID.displayName = address.displayName;
		return userID;
	}
	return nil;
}

- (MMXInternalAddress *)address {
	MMXInternalAddress *address = [MMXInternalAddress new];
	address.username = [self.username jidEscapedString];
	address.displayName = self.displayName;
	return address;
}

+ (NSString *)stripUsername:(NSString *)fullUser {
	NSString* percentage = @"%";
	NSRange range = [fullUser rangeOfString:percentage];
	if (range.location!= NSNotFound) {
		NSString* username = [fullUser substringToIndex:range.location];
		return username;
	} else {
		return fullUser;
	}
}

@end
