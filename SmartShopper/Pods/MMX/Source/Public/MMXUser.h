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

#import <Foundation/Foundation.h>
#import "MMXAddressable.h"
#import <Mantle/Mantle.h>

@interface MMXUser : MTLModel <MMXAddressable>

/**
 *  Unique username the user.
 *  The valid character set is alphanumeric plus period, dash, underscore and "at".   .-_@
 */
@property(nonatomic, copy) NSString *username;

/**
 *  The name you want to have publicly displayed for the user.
 *  The valid character set is alphanumeric plus period, dash, underscore and "at".   .-_@
 */
@property  (nonatomic, copy) NSString *displayName;

/**
 *  Get the currently logged in user
 *
 *  @return MMXUser object for the currently logged in user.
 */
+ (MMXUser *)currentUser;

/**
 *  Method to register a new user with Magnet Message.
 *	If the displayName is not set it will default to the same value as the username.
 *
 *  @param credential - NSURLCredential object containing the user's username and password.
 *  @param success 	  - Block called if operation is successful.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
- (void)registerWithCredential:(NSURLCredential *)credential
					   success:(void (^)(void))success
					   failure:(void (^)(NSError * error))failure;

/**
 *  Method to log in to Magnet Message
 *
 *  @param credential - NSURLCredential object containing the user's username and password.
 *  @param success 	  - Block with the MMXUser object for the newly logged in user.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
+ (void)logInWithCredential:(NSURLCredential *)credential
					success:(void (^)(MMXUser *user))success
					failure:(void (^)(NSError * error))failure;

/**
 *  Log out the currently logged in user.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
+ (void)logOutWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError *error))failure;

/**
 *  Method to change the user's displayName if the user is currently logged in.
 *
 *  @param displayName	- NSString object with the new value for the user's displayName.
 *  @param success		- Block called if operation is successful.
 *  @param failure		- Block with an NSError with details about the call failure.
 */
- (void)changeDisplayName:(NSString *)displayName
				  success:(void (^)(void))success
				  failure:(void (^)(NSError * error))failure;

/**
 *  Method to change the user's password if the user is currently logged in.
 *
 *  @param credential - NSURLCredential object containing the user's username and password.
 *  @param success    - Block called if operation is successful.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
- (void)changePasswordWithCredential:(NSURLCredential *)credential
							 success:(void (^)(void))success
							 failure:(void (^)(NSError * error))failure;

/**
 * @deprecated This method is deprecated starting in version 1.9
 * @note Please use @code findByDisplayName:limit:offset:success:failure: @code instead.
 */
+ (void)findByDisplayName:(NSString *)displayName
					limit:(int)limit
				  success:(void (^)(int totalCount, NSArray *users))success
				  failure:(void (^)(NSError *error))failure __attribute__((deprecated));

/**
 *  Method used to discover existing users by displayName.
 *	You cannot pass an empty string.
 *  The valid character set is alphanumeric plus period, dash, underscore and "at". .-_@
 *
 *  @param displayName	The start of the displayName for the user you are searching for.
 *  @param limit		The max number of results you want returned. Defaults to 20.
 *  @param offset		The offset into the results list. Used for pagination.
 *  @param success		Block with the number of users that match the query and a NSArray of MMXUsers that match the criteria.
 *  @param failure		Block with an NSError with details about the call failure.
 */
+ (void)findByDisplayName:(NSString *)displayName
					limit:(int)limit
				   offset:(int)offset
				  success:(void (^)(int totalCount, NSArray *users))success
				  failure:(void (^)(NSError *error))failure;

/**
 *  Method used to discover all existing users.
 *
 *  @param limit	The max number of results you want returned. Defaults to 20.
 *  @param offset	The offset into the results list. Used for pagination.
 *  @param success	Block with the number of users that match the query and a NSArray of MMXUsers that match the criteria.
 *  @param failure	Block with an NSError with details about the call failure.
 */
+ (void)allUsersWithLimit:(int)limit
				   offset:(int)offset
				  success:(void (^)(int totalCount, NSArray *users))success
				  failure:(void (^)(NSError *error))failure;

/**
 *  Method for getting the full user object from a username
 *
 *  @param username The username for the user you want
 *  @param success 	Block with the MMXUser object for the user.
 *  @param failure  Block with an NSError with details about the call failure.
 */
+ (void)userForUsername:(NSString *)username
				success:(void (^)(MMXUser *user))success
				failure:(void (^)(NSError *error))failure;


//MMXAddressable Protocol
@property (nonatomic, readonly) MMXInternalAddress *address;

@end
