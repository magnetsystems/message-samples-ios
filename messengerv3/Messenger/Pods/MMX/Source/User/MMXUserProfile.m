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

#import "MMXUserProfile.h"
#import "MMXUserProfile_Private.h"
#import "MMXConstants.h"
#import "XMPP.h"
#import "NSString+XEP_0106.h"

@implementation MMXUserProfile

+ (instancetype)initWithUsername:(NSString *)username
                     displayName:(NSString *)displayName
						   email:(NSString *)email
							tags:(NSArray *)tags {
	
	MMXUserProfile * user = [[MMXUserProfile alloc] init];
	user.userID = [MMXUserID userIDWithUsername:username];;
	user.displayName = displayName;
	user.email = email;
	user.tags = tags;
    return user;
 
}

+ (instancetype)initWithDictionary:(NSDictionary *)userDict {
	MMXUserProfile * user = [[MMXUserProfile alloc] init];
	NSString * username = [MMXUserID stripUsername:userDict[@"userId"]];
	user.userID = [MMXUserID userIDWithUsername:[username jidUnescapedString]];;
	user.displayName = userDict[@"displayName"];
	user.email = userDict[@"email"];
	return user;
}

- (NSDictionary *)creationRequestDictionaryWithAppID:(NSString *)appID
											  APIKey:(NSString *)apiKey
									 anonymousSecret:(NSString *)anonymousSecret
										  createMode:(NSString *)createMode
											password:(NSString *)password {
    return @{@"apiKey": apiKey,
             @"priKey": anonymousSecret,
			 @"appId": appID,
			 @"userId": self.userID.username,
             @"password": password,
             @"email": self.email ? self.email : [NSNull null],
             @"createMode": createMode,
             @"displayName": self.displayName,
			 @"tags":self.tags ? self.tags : [NSNull null]};
}


+ (instancetype)recipientWithUsername:(NSString *)username {
    MMXUserProfile * user = [MMXUserProfile initWithUsername:username displayName:@"" email:@"" tags:nil];
    return user;
}

+ (instancetype)userFromIQ:(XMPPIQ *)iq username:(NSString *)username {
	NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement];
	NSString * email;
	NSString * displayName;
	if (mmxElement) {
		NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
		NSError* error;
		NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (jsonDictionary[@"displayName"]) {
			displayName = jsonDictionary[@"displayName"];
		}
		if (jsonDictionary[@"email"]) {
			email = jsonDictionary[@"email"];
		}
	} else {
		return nil;
	}
	MMXUserProfile * user = [MMXUserProfile initWithUsername:username displayName:displayName email:email tags:nil];
	return user;
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"username::%@\ndisplayName::%@\nemail::%@\ntags::%@\n",
                             self.userID.username, self.displayName, self.email,self.tags
                             ];
    return description;
}

#pragma mark - MMXAddressable

- (MMXInternalAddress *)address {
	MMXInternalAddress *address = [MMXInternalAddress new];
	address.username = [self.userID.username jidEscapedString];
	address.displayName = self.displayName;
	return address;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
		_userID = [coder decodeObjectForKey:@"_userID"];
        _displayName = [coder decodeObjectForKey:@"_displayName"];
        _email = [coder decodeObjectForKey:@"_email"];
        _tags = [coder decodeObjectForKey:@"_tags"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.userID forKey:@"_userID"];
	[coder encodeObject:self.displayName forKey:@"_displayName"];
    [coder encodeObject:self.email forKey:@"_email"];
    [coder encodeObject:self.tags forKey:@"_tags"];
}

@end
