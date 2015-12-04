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
#import "MMService.h"

@class MMPasswordResetRequest;
@class MMCall;
@class MMUser;


@protocol MMUserServiceProtocol <NSObject>

@optional
/**
 
 POST /api/com.magnet.server/user/password/reset
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)requestPasswordRest:(MMPasswordResetRequest *)body
                        success:(void (^)(BOOL response))success
                        failure:(void (^)(NSError *error))failure;
/**
 
 POST /api/com.magnet.server/user/session
 @param grant_type style:FORM
 @param username style:FORM
 @param password style:FORM
 @param client_id style:FORM
 @param scope style:FORM
 @param remember_me style:FORM
 @param mMSDEVICEID(original name : MMS-DEVICE-ID) style:HEADER
 @param authorization(original name : Authorization) style:HEADER
 @return A 'MMCall' object.
 */
- (MMCall *)login:(NSString *)grant_type
         username:(NSString *)username
         password:(NSString *)password
        client_id:(NSString *)client_id
            scope:(NSString *)scope
      remember_me:(BOOL)remember_me
      mMSDEVICEID:(NSString *)mMSDEVICEID
    authorization:(NSString *)authorization
          success:(void (^)(NSString *response))success
          failure:(void (^)(NSError *error))failure;
/**
 
 DELETE /api/com.magnet.server/user/session
 @return A 'MMCall' object.
 */
- (MMCall *)logoutWithSuccess:(void (^)(BOOL response))success
                      failure:(void (^)(NSError *error))failure;
/**
 
 POST /api/com.magnet.server/user/enrollment
 @param body style:BODY
 @return A 'MMCall' object.
 */
- (MMCall *)register:(MMUser *)body
             success:(void (^)(MMUser *response))success
             failure:(void (^)(NSError *error))failure;

/**
 
 GET /com.magnet.server/user/query
 @param q style:QUERY
 @param take style:QUERY
 @param skip style:QUERY
 @param sort style:QUERY
 @return A 'MMCall' object.
 */
- (MMCall *)searchUsers:(NSString *)q
                   take:(int)take
                   skip:(int)skip
                   sort:(NSString *)sort
                success:(void (^)(NSArray <MMUser *>*response))success
                failure:(void (^)(NSError *error))failure;

/**
 
 GET /com.magnet.server/user/users
 @param userNames style:QUERY
 @return A 'MMCall' object.
 */
- (MMCall *)getUsersByUserNames:(NSArray <NSString *>*)userNames
                        success:(void (^)(NSArray <MMUser *>*response))success
                        failure:(void (^)(NSError *error))failure;

/**
 
 GET /com.magnet.server/user/users/ids
 @param userIds style:QUERY
 @return A 'MMCall' object.
 */
- (MMCall *)getUsersByUserIds:(NSArray <NSString *>*)userIds
                      success:(void (^)(NSArray <MMUser *>*response))success
                      failure:(void (^)(NSError *error))failure;

@end

@interface MMUserService : MMService<MMUserServiceProtocol>

@end
