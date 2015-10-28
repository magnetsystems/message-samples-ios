/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <AFNetworking/AFSecurityPolicy.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import "MMServiceAdapter_Private.h"
#import "MMService.h"
#import "MMEndPoint.h"
#import "MMWebSocketRequestOperationManager.h"
#import "MMHTTPUtilities.h"
#import "MMHTTPRequestOperationManager.h"

#import "MMDevice.h"
#import "MMDeviceService.h"
#import "MMUser.h"
#import "MMUserService.h"
#import "MMUserInfoService.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>
#import <libextobjc/extobjc.h>

@interface MMRequestFacadeImpl : NSObject<MMRequestFacade>

@property(nonatomic, readonly) NSDictionary *allHTTPHeaderFields;

@property(nonatomic, readonly) NSDictionary *allPathParameterFields;

@property(nonatomic, readonly) NSDictionary *allQueryParameterFields;

@end

NSString * const MMServiceAdapterDidReceiveConfigurationNotification = @"com.magnet.networking.configuration.receive";
NSString * const MMServiceAdapterDidReceiveCATTokenNotification = @"com.magnet.networking.cattoken.receive";
NSString * const MMServiceAdapterDidReceiveHATTokenNotification = @"com.magnet.networking.hattoken.receive";
NSString * const MMServiceAdapterDidInvalidateHATTokenNotification = @"com.magnet.networking.hattoken.invalidate";
NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeNotification = @"com.magnet.networking.challenge.receive";
NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeURLKey = @"com.magnet.networking.challenge.receive.url";

@implementation MMRequestFacadeImpl {
    NSMutableDictionary *_HTTPHeaderFields;
    NSMutableDictionary *_pathParameterFields;
    NSMutableDictionary *_queryParameterFields;
}

- (NSDictionary *)allHTTPHeaderFields {
    return [_HTTPHeaderFields copy];
}

- (NSDictionary *)allPathParameterFields {
    return [_pathParameterFields copy];
}

- (NSDictionary *)allQueryParameterFields {
    return [_queryParameterFields copy];
}


- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (!_HTTPHeaderFields) {
        _HTTPHeaderFields = [NSMutableDictionary dictionary];
    }
    _HTTPHeaderFields[field] = value;
}

- (void)addValue:(NSString *)value forPathParameterField:(NSString *)field {
    [self ensurePathParameterFields];
    // TODO: Encode value
    _pathParameterFields[field] = value;
}

- (void)addEncodedValue:(NSString *)value forPathParameterField:(NSString *)field {
    [self ensurePathParameterFields];
    _pathParameterFields[field] = value;
}

- (void)ensurePathParameterFields {
    if (!_pathParameterFields) {
        _pathParameterFields = [NSMutableDictionary dictionary];
    }
}

- (void)addValue:(NSString *)value forQueryParameterField:(NSString *)field {
    [self ensureQueryParameterFields];
    // TODO: Encode value
    _queryParameterFields[field] = value;
}

- (void)addEncodedValue:(NSString *)value forQueryParameterField:(NSString *)field {
    [self ensureQueryParameterFields];
    _queryParameterFields[field] = value;
}

- (void)ensureQueryParameterFields {
    if (!_queryParameterFields) {
        _queryParameterFields = [NSMutableDictionary dictionary];
    }
}

@end

@implementation MMClient

@synthesize timeoutInterval = _timeoutInterval;
@synthesize securityPolicy = _securityPolicy;

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = 60;
    }

    return self;
}

+ (instancetype)client {
    return [[self alloc] init];
}

@end

@implementation MMProfiler

@synthesize beforeCallData = _beforeCallData;
@synthesize completion = _requestCompletion;

+ (instancetype)profiler {
    return [[self alloc] init];
}

+ (instancetype)profilerWithBeforeCallData:(id)data
                                completion:(void (^)(id requestInfo, long elapsedTime, int statusCode, id beforeCallData))completion {
    MMProfiler *profiler = [MMProfiler profiler];
    profiler.beforeCallData = data;
    profiler.completion = completion;

    return profiler;
}


@end

NSString *const kMMDeviceUUIDKey = @"kMMDeviceUUIDKey";

@implementation MMServiceAdapter

- (id)createService:(Class)serviceClass {

    NSAssert([serviceClass isSubclassOfClass:[MMService class]], @"");

    if (self.requestInterceptor) {
        MMRequestFacadeImpl *requestFacade = [[MMRequestFacadeImpl alloc] init];
        self.requestInterceptor(requestFacade);
//        requestFacade.allHTTPHeaderFields;
//        requestFacade.allPathParameterFields;
//        requestFacade.allQueryParameterFields;
    }
    
    return [[serviceClass alloc] init];
}

+ (instancetype)adapter {
    MMServiceAdapter *adapter = [[self alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:adapter selector:@selector(networkingTaskDidComplete:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    return adapter;
}

- (void)networkingTaskDidComplete:(NSNotification *)notification {

    NSURLSessionTask *task = [notification object];
    NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;

    if (response.statusCode == 401) {

        NSError *error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *jsonError;
        NSDictionary *errorDictionary = [[AFJSONResponseSerializer serializer] responseObjectForResponse:response data:errorData error:&jsonError];

        // Cant use jsonError here as the response statusCode is 401
//        if (!jsonError) {
        NSURL *authorizeUrl = [NSURL URLWithString:errorDictionary[@"authorize_uri"]];
        NSDictionary *userInfo = nil;
        if (authorizeUrl) {
            userInfo = @{
                         MMServiceAdapterDidReceiveAuthenticationChallengeURLKey : authorizeUrl,
                         };
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveAuthenticationChallengeNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
}

- (void)dealloc {
    if (self.isSchemeHTTP) {
        [self.sessionManager.reachabilityManager stopMonitoring];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)adapterWithConfiguration:(id<MMServiceAdapterConfiguration>)configuration {
    return [self adapterWithConfiguration:configuration client:nil];
}

+ (instancetype)adapterWithConfiguration:(id<MMServiceAdapterConfiguration>)configuration
                                  client:(id<MMClientFacade>)client {
    return [self adapterWithEndpoint:[MMEndPoint endPointWithURL:configuration.baseURL] clientID:configuration.clientID clientSecret:configuration.clientSecret client:client];
}

+ (instancetype)adapterWithEndpoint:(MMEndPoint *)endpoint clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret {
    return [self adapterWithEndpoint:endpoint clientID:clientID clientSecret:clientSecret client:nil];
}

+ (instancetype)adapterWithEndpoint:(MMEndPoint *)endpoint
                           clientID:(NSString *)clientID
                       clientSecret:(NSString *)clientSecret
                             client:(id<MMClientFacade>)client {
    MMServiceAdapter * serviceAdapter = [self adapter];
    serviceAdapter.clientID = clientID;
    serviceAdapter.clientSecret = clientSecret;
    NSURL *url = endpoint.URL;
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        endpoint.URL = [url URLByAppendingPathComponent:@""];
    }
    serviceAdapter.endPoint = endpoint;
    serviceAdapter.client = client;
    serviceAdapter.currentCATTokenRequestStatus = MMCATTokenRequestStatusInProgress;


    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration registerURLProtocolClass:[MMURLProtocol class]];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:endpoint.URL sessionConfiguration:configuration];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (serviceAdapter.client.securityPolicy) {
        sessionManager.securityPolicy = serviceAdapter.client.securityPolicy;
    }
    serviceAdapter.sessionManager = sessionManager;
    
    
    if (serviceAdapter.isSchemeHTTP) {
        @weakify(serviceAdapter);
        serviceAdapter.networkReachabilityStatusBlock = ^(AFNetworkReachabilityStatus status) {
            @strongify(serviceAdapter);
            NSOperationQueue *operationQueue = serviceAdapter.requestOperationManager.reliableOperationQueue;
            operationQueue.suspended = YES;
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    operationQueue.suspended = NO;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    operationQueue.suspended = YES;
                    break;
            }
        };
        [serviceAdapter.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:serviceAdapter.networkReachabilityStatusBlock];

        [serviceAdapter.sessionManager.reachabilityManager startMonitoring];
    }
    
    [serviceAdapter authorizeApplicationWithSuccess:^(AFOAuthCredential *credential) {
        serviceAdapter.currentCATTokenRequestStatus = MMCATTokenRequestStatusDone;
    } failure:^(NSError *error) {
        serviceAdapter.currentCATTokenRequestStatus = MMCATTokenRequestStatusFailed;
    }];

    return serviceAdapter;
}

- (void)registerCurrentDeviceWithSuccess:(void (^)(MMDevice *response))success
                                 failure:(void (^)(NSError *error))failure {
	
    MMCall *call = [self.deviceService registerDevice:self.currentDevice authorization:nil success:^(MMDevice *response) {
        if (success) {
            success(response);
        }
    }
    failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

    [call executeInBackground:nil];
}

- (void)authorizeApplicationWithSuccess:(void (^)(AFOAuthCredential *credential))success
								failure:(void (^)(NSError *error))failure {
	
    self.authManager = [[AFOAuth2Manager alloc] initWithBaseURL:self.endPoint.URL
                                                       clientID:self.clientID/*kClientID*/
                                                         secret:self.clientSecret/*kClientSecret*/];
    
    [self.authManager.requestSerializer setValue:[MMServiceAdapter deviceUUID] forHTTPHeaderField:@"MMS-DEVICE-ID"];
    [self.authManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    self.authManager.operationQueue = nil;
#pragma clang diagnostic pop
	
	AFHTTPRequestOperation *afOperation = [self.authManager authenticateUsingOAuthWithURLString:@"com.magnet.server/applications/session" scope:@"APPLICATION" success:nil failure:nil];
	
//	// Create a NSOperationQueue here
	self.CATTokenOperation = [self.requestOperationManager requestOperationWithRequest:afOperation.request
																					  success:^(NSURLResponse *response, id responseObject) {
		AFOAuthCredential *credential;
		if (responseObject) {
            [self setAppIdFromResponseObject:responseObject];
			credential = [MMServiceAdapter credentialFromResponseObject:responseObject];
		}
		if (credential) {
			self.CATToken = credential.accessToken;
			self.currentCATTokenRequestStatus = MMCATTokenRequestStatusDone;

            self.applicationAuthenticationError = nil;
			[self passAppTokenToRegisteredServices];
            if (success) {
                success(credential);
            }
		} else {
            // FIXME:
            if (failure) {
                failure(nil);
            }
			self.currentCATTokenRequestStatus = MMCATTokenRequestStatusFailed;
		}
                                                                                          [self registerCurrentDeviceWithSuccess:nil failure:nil];

	} failure:^(NSError *error) {
		self.currentCATTokenRequestStatus = MMCATTokenRequestStatusFailed;
		self.applicationAuthenticationError = error;
	}];
	[self.requestOperationManager.operationQueue addOperation:self.CATTokenOperation];
}

//FIXME: This needs to be refactored. Just trying to get things working right now.
- (void)setAppIdFromResponseObject:(id)responseObject {
	NSDictionary *jsonDictionary;
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		jsonDictionary = responseObject;
	} else if ([responseObject isKindOfClass:[NSData class]]) {
		NSError *error;
		jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error) {
			return;
		}
	} else {
		return;
	}
	if (jsonDictionary[@"mmx_app_id"] && [jsonDictionary[@"mmx_app_id"] isKindOfClass:[NSString class]]) {
		self.mmxAppId = jsonDictionary[@"mmx_app_id"];
	}
}

+ (AFOAuthCredential *)credentialFromResponseObject:(id)responseObject {
	
	NSDictionary *jsonDictionary;
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		jsonDictionary = responseObject;
	} else if ([responseObject isKindOfClass:[NSData class]]) {
		NSError *error;
		jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error) {
			return nil;
		}
	} else {
		return nil;
	}
	
	//FIXME: Add the refresh token funtionality in after it is supported
//	NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
//	if (!refreshToken || [refreshToken isEqual:[NSNull null]]) {
//	 refreshToken = [parameters valueForKey:@"refresh_token"];
//	}
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:jsonDictionary[@"config"]];
    configuration[@"mmx-appId"] = jsonDictionary[@"mmx_app_id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveConfigurationNotification object:self userInfo:configuration];

	AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[jsonDictionary valueForKey:@"access_token"] tokenType:[jsonDictionary valueForKey:@"token_type"]];

	//	if (refreshToken) { // refreshToken is optional in the OAuth2 spec
	//	 [credential setRefreshToken:refreshToken];
	//	}


	// Expiration is optional, but recommended in the OAuth2 spec. It not provide, assume distantFuture === never expires
	NSDate *expireDate = [NSDate distantFuture];
	id expiresIn = [jsonDictionary valueForKey:@"expires_in"];
	if (expiresIn && ![expiresIn isEqual:[NSNull null]]) {
	 expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
	}

	if (expireDate) {
	 [credential setExpiration:expireDate];
	}
	return credential;
}

- (MMCall *)registerUser:(MMUser *)user
			 success:(void (^)(MMUser *registeredUser))success
			 failure:(void (^)(NSError *error))failure {
	
    return [self callRegisterUser:user success:success failure:failure];
}

- (MMCall *)callRegisterUser:(MMUser *)user
				     success:(void (^)(MMUser *registeredUser))success
				     failure:(void (^)(NSError *error))failure {
    // Set default values
    if(!user.userRealm) {
        user.userRealm = MMUserRealmDB;
    }

    MMCall *call = [self.userService register:user success:^(MMUser *registeredUser) {
        if (success) {
            success(registeredUser);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

    return call;
}


//FIXME: loginWithUsername will NOT work over web sockets yet
- (MMCall *)loginWithUsername:(NSString *)username
                     password:(NSString *)password
                      success:(void (^)(BOOL successful))success
                      failure:(void (^)(NSError *error))failure {
	
    NSDictionary * params = @{@"grant_type":@"password",
							  @"username":username,
							  @"password":password,
							  @"client_id":self.clientID,
							  @"scope":@"anonymous"};
    NSOperation *operation = [self.authManager authenticateUsingOAuthWithURLString:@"com.magnet.server/user/session" parameters:params
                                                                        success:^(AFOAuthCredential *credential) {
                                                                            self.username = username;
                                                                            self.HATToken = credential.accessToken;
                                                                            [self registerCurrentDeviceWithSuccess:nil failure:nil];
//                                                                            if (self.HATToken) {
//                                                                                [self passUserTokenToRegisteredServices];
//                                                                            }
                                                                            if (success) {
                                                                                success(YES);
                                                                            }
                                                                        } failure:^(NSError *error) {
                                                                            if (failure) {
                                                                                failure(error);
                                                                            }
                                                                        }];

    NSString *correlationId = [[NSUUID UUID] UUIDString];
    NSDictionary *metaData = [[MMUserService class] metaData];
    NSString *selectorString = NSStringFromSelector(@selector(login:username:password:client_id:scope:remember_me:mMSDEVICEID:authorization:success:failure:));
    MMServiceMethod *method = metaData[selectorString];

    
    NSMutableURLRequest *unusedRequest = [[NSMutableURLRequest alloc] init];
    MMCall *call = [[MMCall alloc] initWithCallID:correlationId serviceAdapter:self serviceMethod:method request:unusedRequest underlyingOperation:operation];

    return call;
}

- (MMCall *)logoutWithSuccess:(void (^)(BOOL response))success failure:(void (^)(NSError *error))failure {
    // Unregister device
    MMCall *call = [self.deviceService unRegisterDevice:[MMServiceAdapter deviceUUID] authorization:self.HATToken success:^(BOOL response) {

    } failure:^(NSError *error) {
//        NSLog(@"Failed to unregister device when logout");
    }];
    [call executeInBackground:nil];

    return [self.userService logoutWithSuccess:^(BOOL response) {
        if(success) {
            // Clean up
            self.HATToken = nil;
            [self invalidateUserTokenInRegisteredServices];
            self.username = nil;
            if (success) {
                success(response);
            }
        }
    } failure:^(NSError *error) {
        if(failure) {
            failure(error);
        }
    }];
}

- (MMCall *)getCurrentUserWithSuccess:(void (^)(MMUser *response))success
                           failure:(void (^)(NSError *error))failure {
    return [self.userInfoService getUserInfoWithSuccess:^(MMUser *response) {
        if(success) {
            success(response);
        }
    } failure:^(NSError *error) {
        if(failure) {
            failure(error);
        }
    }];
}

- (void)resendReliableCalls {
    
    // FIXME: How to access a protocol extension from Objective-C
    // Use [MMReliableCall sortedFetchRequest]
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MMReliableCall entityName]];
    NSError *error;
    NSArray<MMReliableCall *> __unused *pendingReliableCalls = [[MMCoreDataStack sharedContext] executeFetchRequest:fetchRequest error:&error];
}

- (void)cancelAllOperations {
    [self.requestOperationManager.operationQueue cancelAllOperations];
    // FIXME: Delete from local store
    [self.requestOperationManager.reliableOperationQueue cancelAllOperations];
}

- (NSString *)bearerAuthorization {
	return [NSString stringWithFormat:@"Bearer %@",self.HATToken ?: self.CATToken];
}

- (BOOL)isSchemeHTTP {
    BOOL isSchemeHTTP = NO;

    NSString *scheme = self.endPoint.URL.scheme;
    if (MMDoesSchemeHaveHTTPPrefix(scheme)) {
        isSchemeHTTP = YES;
    } else if (MMDoesSchemeHaveWSPrefix(scheme)) {
        isSchemeHTTP = NO;
    }

    return isSchemeHTTP;
}


- (NSError *)unknownError {
	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey: NSLocalizedString(@"Something went wrong.", nil),
							   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An unknown error occured.", nil),
							   };
	NSError *error = [NSError errorWithDomain:@"MMErrorDomain"
										 code:500
									 userInfo:userInfo];
	return error;
}

+ (NSString *)deviceUUID {
	NSString *savedDeviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kMMDeviceUUIDKey];
	if (savedDeviceUUID && ![savedDeviceUUID isEqualToString:@""]) {
		return savedDeviceUUID;
	}
	NSString * newDeviceUUID = [[NSUUID UUID] UUIDString];
	[[NSUserDefaults standardUserDefaults] setObject:newDeviceUUID forKey:kMMDeviceUUIDKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return newDeviceUUID;
}

- (NSString *)basicAuthorization {
	NSData *nsdata = [[NSString stringWithFormat:@"%@:%@",self.clientID,self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
 
	return [NSString stringWithFormat:@"Basic %@",[nsdata base64EncodedStringWithOptions:0]];
}

#pragma mark - Overriden getters

- (id<MMRequestOperationManager>)requestOperationManager {
    if (!_requestOperationManager) {
        NSString *scheme = self.endPoint.URL.scheme;
        if (MMDoesSchemeHaveHTTPPrefix(scheme)) {
            MMHTTPRequestOperationManager *requestOperationManager = [[MMHTTPRequestOperationManager alloc] initWithBaseURL:self.endPoint.URL];
            requestOperationManager.manager = self.sessionManager;
            _requestOperationManager = requestOperationManager;
        } else if (MMDoesSchemeHaveWSPrefix(scheme)) {
            self.endPoint.URL = [self.endPoint.URL URLByAppendingPathComponent:@"ws"];
            _requestOperationManager = [[MMWebSocketRequestOperationManager alloc] initWithBaseURL:self.endPoint.URL];
        }
        _requestOperationManager.securityPolicy = self.client.securityPolicy;
    }

    return _requestOperationManager;
}

- (NSMutableDictionary *)services {
    if (!_services) {
        _services = [NSMutableDictionary dictionary];
    }

    return _services;
}

- (MMUserService *) userService {
    if(!_userService) {
        _userService = [self createService:MMUserService.class];
    }

    return _userService;
}

- (MMDeviceService *) deviceService {
    if(!_deviceService) {
        _deviceService = [self createService:MMDeviceService.class];
    }

    return _deviceService;
}

- (MMUserInfoService *) userInfoService {
    if(!_userInfoService) {
        _userInfoService = [self createService:MMUserInfoService.class];
    }

    return _userInfoService;
}

- (MMDevice *)currentDevice {
    if (!_currentDevice) {
        MMDevice *myDevice = [[MMDevice alloc] init];
        myDevice.os = MMOsTypeIOS;
        myDevice.osVersion = [[UIDevice currentDevice] systemVersion];
        myDevice.pushAuthority = MMPushAuthorityTypeAPNS;
        myDevice.deviceID = [MMServiceAdapter deviceUUID];
        myDevice.label = [[UIDevice currentDevice] name];
        
        _currentDevice = myDevice;
    }
    
    return _currentDevice;
}

- (void)passAppTokenToRegisteredServices {
    
    NSString *deviceID = [MMServiceAdapter deviceUUID];
    
    NSDictionary *userInfo = @{
                               @"appID" : self.clientID,
                               @"deviceID" : deviceID,
                               @"token" : self.CATToken
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveCATTokenNotification object:self userInfo:userInfo];
}

- (void)passUserTokenToRegisteredServices {
    
    NSString *deviceID = [MMServiceAdapter deviceUUID];
    
    NSDictionary *userInfo = @{
                               @"userID" : self.username,
                               @"deviceID" : deviceID,
                               @"token" : self.HATToken
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveHATTokenNotification object:self userInfo:userInfo];
}

- (void)invalidateUserTokenInRegisteredServices {
    
    NSString *deviceID = [MMServiceAdapter deviceUUID];
    
    NSDictionary *userInfo = @{
                               @"userID" : self.username,
                               @"deviceID" : deviceID,
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidInvalidateHATTokenNotification object:self userInfo:userInfo];
}

@end
