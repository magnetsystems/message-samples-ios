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

@class MMEndPoint;
@class AFSecurityPolicy;
@class MMUser;
@class MMCall;
@class MMDevice;
@protocol MMConfiguration;
@class MMHTTPSessionManager;
@protocol MMRequestOperationManager;

@protocol MMClientFacade <NSObject>

/**
The timeout interval, in seconds, for created requests. The default timeout interval is 60 seconds.

@see NSMutableURLRequest -setTimeoutInterval:
*/
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

///-------------------------------
/// @name Managing Security Policy
///-------------------------------

/**
 The security policy used by created request operations to evaluate server trust for secure connections. `AFHTTPRequestOperationManager` uses the `defaultPolicy` unless otherwise specified.
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

@end

@interface MMClient : NSObject<MMClientFacade>

+ (instancetype)client;

@end

@interface MMServiceAdapter : NSObject

@property(nonatomic, strong) MMEndPoint *endPoint;

@property(nonatomic, readonly) NSString *refreshToken;

@property(nonatomic, copy) NSString *CATToken;

@property(nonatomic, copy) NSString *HATToken;

@property(nonatomic, strong) id<MMClientFacade> client;

@property(nonatomic, readonly) MMDevice *currentDevice;

@property (nonatomic, strong) MMHTTPSessionManager *backgroundSessionManager;

@property (nonatomic, strong) MMHTTPSessionManager *sessionManager;

@property(nonatomic, strong) id<MMRequestOperationManager> requestOperationManager;

- (id)createService:(Class)serviceClass;

+ (NSString *)deviceUUID;

+ (instancetype)adapter;

+ (instancetype)adapterWithConfiguration:(id<MMConfiguration>)configuration;

+ (instancetype)adapterWithConfiguration:(id<MMConfiguration>)configuration
                                  client:(id<MMClientFacade>)client;

+ (instancetype)adapterWithEndpoint:(MMEndPoint *)endpoint
						   clientID:(NSString *)clientID
					   clientSecret:(NSString *)clientSecret;

+ (instancetype)adapterWithEndpoint:(MMEndPoint *)endpoint
                           clientID:(NSString *)clientID
                       clientSecret:(NSString *)clientSecret
                             client:(id<MMClientFacade>)client;

- (NSString *)bearerAuthorization;

- (MMCall *)registerUser:(MMUser *)user
                 success:(void (^)(MMUser *registeredUser))success
                 failure:(void (^)(NSError *error))failure;

- (MMCall *)loginWithUsername:(NSString *)username
                     password:(NSString *)password
                   rememberMe:(BOOL)rememberMe
                      success:(void (^)(BOOL successful))success
                      failure:(void (^)(NSError *error))failure;

- (MMCall *)logoutWithSuccess:(void (^)(BOOL response))success
                      failure:(void (^)(NSError *error))failure;

- (MMCall *)getCurrentUserWithSuccess:(void (^)(MMUser *response))success
                           failure:(void (^)(NSError *error))failure;

- (void)registerCurrentDeviceWithSuccess:(void (^)(MMDevice *response))success
                                 failure:(void (^)(NSError *error))failure;

- (void)resendReliableCalls;

- (void)cancelAllOperations;

- (void)authenticateApplicationWithSuccess:(void (^)())success
                                   failure:(void (^)(NSError *error))failure;

- (void)authenticateUserWithSuccess:(void (^)())success
                            failure:(void (^)(NSError *error))failure;

/**
 * Posted when (additional) configuration is received.
 */
extern NSString *const MMServiceAdapterDidReceiveConfigurationNotification;

/**
 * Posted when an app (CAT) token is received.
 */
extern NSString *const MMServiceAdapterDidReceiveCATTokenNotification;

/**
 * Posted when an user (HAT) token is received.
 */
extern NSString *const MMServiceAdapterDidReceiveHATTokenNotification;

/**
 * Posted when an user (HAT) token is invalidated.
 */
extern NSString *const MMServiceAdapterDidInvalidateHATTokenNotification;

/**
 * Posted when an invalid set of clientID/clientSecret are used to configure MagnetMax.
 */
extern NSString *const MMServiceAdapterDidReceiveInvalidCATTokenNotification;

/**
 * Posted when an OAuth Login Exception is received.
 */
extern NSString *const MMServiceAdapterDidReceiveAuthenticationChallengeNotification;

/**
 Any URL associated with the challenge. Included in the userInfo dictionary of the `MMServiceAdapterDidReceiveAuthenticationChallengeNotification` if an URL exists.
 */
extern NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeURLKey;

@end
