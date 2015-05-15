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

@implementation MMXUserID

+ (instancetype)userIDWithUsername:(NSString *)username {
	MMXUserID * userID = [[MMXUserID alloc] init];
	userID.username = username;
	return userID;
}

- (NSString *)address {
	return self.username;
}

- (NSString *)subAddress {
	return nil;
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		_username = [coder decodeObjectForKey:@"_username"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.username forKey:@"_username"];
}

- (id)copyWithZone:(NSZone *)zone {
	MMXUserID *copy = [[[self class] allocWithZone:zone] init];
	
	if (copy != nil) {
		copy.username = self.username;
	}
	
	return copy;
}


@end
