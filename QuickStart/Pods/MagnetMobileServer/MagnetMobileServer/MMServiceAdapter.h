/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class MMEndPoint;
@class AFSecurityPolicy;
@class MMUser;
@class MMCall;
@class MMDevice;
@protocol MMServiceAdapterConfiguration;
@class AFHTTPSessionManager;
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

@protocol MMRequestFacade <NSObject>

@required

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

- (void)addValue:(NSString *)value forPathParameterField:(NSString *)field;

- (void)addEncodedValue:(NSString *)value forPathParameterField:(NSString *)field;

- (void)addValue:(NSString *)value forQueryParameterField:(NSString *)field;

- (void)addEncodedValue:(NSString *)value forQueryParameterField:(NSString *)field;

@end

@protocol MMProfilerConfiguration <NSObject>

@property(nonatomic, strong) id beforeCallData;

@property(nonatomic, copy) void (^completion)(id requestInfo, long elapsedTime, int statusCode, id beforeCallData);

@end

@interface MMProfiler : NSObject <MMProfilerConfiguration>

+ (instancetype)profiler;

+ (instancetype)profilerWithBeforeCallData:(id)data
                                completion:(void (^)(id requestInfo, long elapsedTime, int statusCode, id beforeCallData))completion;

@end

@interface MMServiceAdapter : NSObject

@property(nonatomic, strong) MMEndPoint *endPoint;

@property(nonatomic, copy) NSString *HATToken;

@property(nonatomic, copy) void (^requestInterceptor)(id<MMRequestFacade> request);

@property(nonatomic, strong) id<MMProfilerConfiguration> profiler;

@property(nonatomic, strong) id<MMClientFacade> client;

@property(nonatomic, readonly) MMDevice *currentDevice;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property(nonatomic, strong) id<MMRequestOperationManager> requestOperationManager;

- (id)createService:(Class)serviceClass;

+ (NSString *)deviceUUID;

+ (instancetype)adapter;

+ (instancetype)adapterWithConfiguration:(id<MMServiceAdapterConfiguration>)configuration;

+ (instancetype)adapterWithConfiguration:(id<MMServiceAdapterConfiguration>)configuration
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
                      success:(void (^)(BOOL success))success
                      failure:(void (^)(NSError *error))failure;

- (MMCall *)logoutWithSuccess:(void (^)(BOOL response))success
                      failure:(void (^)(NSError *error))failure;

- (MMCall *)getCurrentUserWithSuccess:(void (^)(MMUser *response))success
                           failure:(void (^)(NSError *error))failure;

- (void)registerCurrentDeviceWithSuccess:(void (^)(MMDevice *response))success
                                 failure:(void (^)(NSError *error))failure;

- (void)resendReliableCalls;

- (void)cancelAllOperations;

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
 * Posted when an OAuth Login Exception is received.
 */
extern NSString *const MMServiceAdapterDidReceiveAuthenticationChallengeNotification;

/**
 Any URL associated with the challenge. Included in the userInfo dictionary of the `MMServiceAdapterDidReceiveAuthenticationChallengeNotification` if an URL exists.
 */
extern NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeURLKey;

@end
