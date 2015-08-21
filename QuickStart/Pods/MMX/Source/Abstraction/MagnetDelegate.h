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
@class MMXMessage;
@class MMXUser;
@class MMXChannel;
@class MMXInternalMessageAdaptor;

@interface MagnetDelegate : NSObject

@property (nonatomic, strong) MMXUser *currentUser;

+ (instancetype)sharedDelegate;

- (void)startMMXClientWithConfiguration:(NSString *)name;

/**
 *  Method to register a new user with Magnet Message
 *
 *  @param user		  - MMXUser for the user you want to register
 *  @param credential - NSURLCredential object containing the user's username and password.
 *  @param success 	  - Block called if operation is successful.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
- (void)registerUser:(MMXUser *)user
		 credentials:(NSURLCredential *)credential
			 success:(void (^)(void))success
			 failure:(void (^)(NSError *))failure;

- (void)connectWithSuccess:(void (^)(void))success
				   failure:(void (^)(NSError *error))failure;
/**
 *  Method to log in to Magnet Message
 *
 *  @param credential - NSURLCredential object containing the user's username and password.
 *  @param success 	  - Block with the MMXUser object for the newly logged in user.
 *  @param failure    - Block with an NSError with details about the call failure.
 */
- (void)logInWithCredential:(NSURLCredential *)credential
					success:(void (^)(MMXUser *))success
					failure:(void (^)(NSError *error))failure;

- (void)privateLogInWithCredential:(NSURLCredential *)credential
						   success:(void (^)(MMXUser *))success
						   failure:(void (^)(NSError *error))failure;


/**
 *  Log out the currently logged in user.
 *
 *  @param success - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)logOutWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError *error))failure;



/**
 *  Method to send the message
 *
 *  @param message - MMXOutboundMessage to send
 *  @param success 	  - Block called if operation is successful.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (NSString *)sendMessage:(MMXMessage *)message
				  success:(void (^)(void))success
				  failure:(void (^)(NSError *error))failure;

- (NSString *)sendInternalMessageFormat:(MMXInternalMessageAdaptor *)message
								success:(void (^)(void))success
								failure:(void (^)(NSError *error))failure;

+ (NSError *)notNotLoggedInError;

@end
