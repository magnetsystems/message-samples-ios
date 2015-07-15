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

@class MMXUserProfile;
@class MMXQuery;
@class MMXUserID;


/**
 *  MMXAccountManager is the primary class interacting with users.
 *	It has many methods for getting and updating the current user's information.
 *	It also contains a method for discovering/querying for other users.
 */
@interface MMXAccountManager : NSObject

/**
 *  Method to register a new user
 *
 *  @param username		- The username for the user you want to create
 *  @param displayName	- The name you want to have publicly displayed for the user. The valid character set is alphanumeric plus period, dash and underscore. .-_
 *  @param email		- The email for the user.
 *  @param password		- Password you wish to set for the user.
 *  @param success		- Block with MMXUserProfile for the newly created user.
 *  @param failure		- Block with an NSError with details about the call failure.
 */
- (void)createAccountForUsername:(NSString *)username
					 displayName:(NSString *)displayName
						   email:(NSString *)email
						password:(NSString *)password
						 success:(void (^)(MMXUserProfile *userProfile))success
						 failure:(void (^)(NSError * error))failure;

/**
 *  The callback dispatch queue. Value is initially set to the main queue.
 */
@property (nonatomic, assign) dispatch_queue_t callbackQueue;

/**
 *  Method to get the MMXUserProfile for the current user.
 *
 *  @param success - Block with MMXUserProfile object of the current user.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)userProfileWithSuccess:(void (^)(MMXUserProfile * user))success
					   failure:(void (^)(NSError * error))failure;

/**
 *  Method for getting the list of MMXEndpoint objects for a user.
 *
 *  @param user    - MMXUserID object for the user you want endpoints for.
 *  @param success - An NSArray of MMXEndpoint objects.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)endpointsForUser:(MMXUserID *)user
				 success:(void (^)(NSArray * endpoints))success
				 failure:(void (^)(NSError * error))failure;

/**
 *  Method to update the email for the current user.
 *
 *  @param email   - The new email you want to set for the current user.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)updateEmail:(NSString *)email
			success:(void (^)(BOOL))success
			failure:(void (^)(NSError *))failure;

/**
 *  Method to update the displayName for the current user.
 *
 *  @param displayName  - The new displayName you want to set for the current user.
 *  @param success		- Block with BOOL. Value should be YES.
 *  @param failure		- Block with an NSError with details about the call failure.
 */
- (void)updateDisplayName:(NSString *)displayName
				  success:(void (^)(BOOL))success
				  failure:(void (^)(NSError *))failure;

/**
 *  Change the current user's password.
 *
 *  @param password	- The new password you want to set for the current user.
 *  @param success	- Block with BOOL. Value should be YES.
 *  @param failure	- Block with an NSError with details about the call failure.
 */
- (void)updatePassword:(NSString *)password
			   success:(void (^)(BOOL))success
			   failure:(void (^)(NSError *))failure;

/**
 *  Method to query for a list of users that fit a particular query criteria.
 *
 *  @param userQuery - MMXUserQuery with the properties set that you wish to query on.
 *  @param success	 - Block with int for total number of results that fit the query. And a NSArray of MMXUserProfile objects.
 *  @param failure	 - Block with an NSError with details about the call failure.
 */
- (void)queryUsers:(MMXQuery *)userQuery
           success:(void (^)(int totalCount, NSArray * users))success
           failure:(void (^)(NSError *))failure;

/**
 *  Method to get the list of tags associated with the current user.
 *
 *  @param success - A block with a NSArray of tags(NSStrings).
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)tagsWithSuccess:(void (^)(NSArray * tags))success
				failure:(void (^)(NSError * error))failure;

/**
 *  Method to add tags to the current user.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to add to the current user.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)addTags:(NSArray *)tags
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure;

/**
 *  Set tags for the current user. This will overwrite ALL existing tags for the user.
 *	This can be used to delete tags by passing in the sub-set of existing tags that you want to keep.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to set for the current user.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)setTags:(NSArray *)tags
		success:(void (^)(BOOL success))success
		failure:(void (^)(NSError * error))failure;

/**
 *  Remove tags for the current user.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to remove from the current user.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)removeTags:(NSArray *)tags
		   success:(void (^)(BOOL success))success
		   failure:(void (^)(NSError * error))failure;


@end