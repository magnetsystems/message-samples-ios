/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMModel.h"
#import "MMUserRealm.h"

@class MMCall;

/**
 The MMUser class is a local representation of a user in the MagnetMax platform. This class provides various user specific methods, like authentication, signing up, and search.
 */
@interface MMUser : MMModel

/**
 The unique identifer for the user.
 */
@property (nonatomic, copy) NSString *userID;

/**
 The username for the user.
 */
@property (nonatomic, copy) NSString *userName;

/**
 The password for the user.
 */
@property (nonatomic, copy) NSString *password;

/**
 The firstName for the user.
 */
@property (nonatomic, copy) NSString *firstName;

/**
 The lastName for the user.
 */
@property (nonatomic, copy) NSString *lastName;

/**
 The email for the user.
 */
@property (nonatomic, copy) NSString *email;

/**
 The roles assigned to the user.
 */
@property (nonatomic, copy) NSArray <NSString *>*roles;

/**
 The realm for the user.
 */
@property (nonatomic, assign) MMUserRealm userRealm;

/**
 The additional key-value pairs associated with the user.
 */
@property (nonatomic, copy) NSDictionary <NSString *, NSString *>*extras;

/**
 The tags associated with the user.
 */
@property (nonatomic, copy) NSArray <NSString *>*tags;

@end
