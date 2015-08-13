//
//  MagnetDelegate.h
//  QuickStart
//
//  Created by Jason Ferguson on 8/5/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMXMessage;
@class MMXUser;

@interface MagnetDelegate : NSObject

@property (nonatomic, strong) MMXUser *currentUser;

+ (instancetype)sharedDelegate;

- (void)startMMXClient;

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

@end
