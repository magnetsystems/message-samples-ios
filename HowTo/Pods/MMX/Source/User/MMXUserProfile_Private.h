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
#import "MMXUserID_Private.h"
@class XMPPIQ;

@interface MMXUserProfile ()

@property  (nonatomic, readwrite) MMXUserID *userID;

/**
 *  Tags are strings to be used later when searching for users.
 *  The valid character set is alphanumeric.
 */
@property  (nonatomic, readwrite) NSArray *tags;

+ (instancetype)initWithDictionary:(NSDictionary *)userDict;

- (NSDictionary *)creationRequestDictionaryWithAppID:(NSString *)appID
											  APIKey:(NSString *)apiKey
									 anonymousSecret:(NSString *)anonymousSecret
										  createMode:(NSString *)createMode
											password:(NSString *)password;

+ (instancetype)userFromIQ:(XMPPIQ *)iq username:(NSString *)username;

/**
 *  Create a new user for the purpose of user registration.
 *
 *  @param username		- The username you wish to set for the user.
 *  @param displayName	- The display name or publicly shown name for the user.
 *  @param email		- The email you wish to set for the user.
 *  @param tags			- A NSArray of tags(NSStrings) that you want to add to the current user.
 *
 *  @return A new MMXUserProfile object for use in user registration
 */
+ (instancetype)initWithUsername:(NSString *)username
					 displayName:(NSString *)displayName
						   email:(NSString *)email
							tags:(NSArray *)tags;
@end