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

#import <AFNetworking/AFSecurityPolicy.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import "MMServiceAdapter_Private.h"
#import "MMService.h"
#import "MMEndPoint.h"
#import "MMHTTPUtilities.h"
#import "MMHTTPRequestOperationManager.h"

#import "MMDevice.h"
#import "MMDeviceService.h"
#import "MMUser.h"
#import "MMUserService.h"
#import "MMUserInfoService.h"
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>
#import "MMCall_Private.h"
#import "MMConfigurationReader.h"
#import "MMRefreshTokenRequest.h"


NSString * const MMServiceAdapterDidReceiveConfigurationNotification = @"com.magnet.networking.configuration.receive";
NSString * const MMServiceAdapterDidReceiveCATTokenNotification = @"com.magnet.networking.cattoken.receive";
NSString * const MMServiceAdapterDidReceiveHATTokenNotification = @"com.magnet.networking.hattoken.receive";
NSString * const MMServiceAdapterDidInvalidateHATTokenNotification = @"com.magnet.networking.hattoken.invalidate";
NSString * const MMServiceAdapterDidReceiveInvalidCATTokenNotification = @"com.magnet.networking.cattoken.challenge.receive";
NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeNotification = @"com.magnet.networking.challenge.receive";
NSString * const MMServiceAdapterDidReceiveAuthenticationChallengeURLKey = @"com.magnet.networking.challenge.receive.url";

NSString * const MMCATTokenIdentifier = @"com.magnet.networking.cattoken";
NSString * const MMHATTokenIdentifier = @"com.magnet.networking.hattoken";

NSString *const kMMDeviceUUIDKey = @"kMMDeviceUUIDKey";
NSString *const kMMConfigurationKey = @"kMMConfigurationKey";

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

@implementation MMServiceAdapter

- (id)createService:(Class)serviceClass {

    NSAssert([serviceClass isSubclassOfClass:[MMService class]], @"");

    return [[serviceClass alloc] init];
}

+ (instancetype)adapter {
    MMServiceAdapter *adapter = [[self alloc] init];
//    [[NSNotificationCenter defaultCenter] addObserver:adapter selector:@selector(networkingTaskDidComplete:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    return adapter;
}

- (void)networkingTaskDidComplete:(NSNotification *)notification {
    
    NSURLSessionTask *task = [notification object];
    NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
    
    if (response.statusCode == 401) {
        NSURLRequest *originalRequest = task.originalRequest;
        // Invalid CAT token request
        
        if ([self isCATTokenRequest:originalRequest]) {
            
            self.CATToken = nil;
            
            NSAssert(NO, @"An invalid set of clientID/clientSecret are used to configure MagnetMax. Please check them again.");
            [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveInvalidCATTokenNotification
                                                                object:nil
                                                              userInfo:nil];
        } else if ([self isLogoutRequest:originalRequest]) {
            // Swallow
        } else {
            
            self.HATToken = nil;
            
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
}

- (BOOL)isCATTokenRequest:(NSURLRequest *)request {
    return (MMRequestMethodFromString(request.HTTPMethod) == MMRequestMethodPOST) && [request.URL.path hasSuffix:@"com.magnet.server/applications/session"];
}

- (BOOL)isLogoutRequest:(NSURLRequest *)request {
    return (MMRequestMethodFromString(request.HTTPMethod) == MMRequestMethodDELETE) && [request.URL.path hasSuffix:[NSString stringWithFormat:@"com.magnet.server/devices/%@", [MMDevice currentDevice].deviceID]];
}

- (void)dealloc {
    if (self.isSchemeHTTP) {
        [self.sessionManager.reachabilityManager stopMonitoring];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)adapterWithConfiguration:(id<MMConfiguration>)configuration {
    return [self adapterWithConfiguration:configuration client:nil];
}

+ (instancetype)adapterWithConfiguration:(id<MMConfiguration>)configuration
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
    MMHTTPSessionManager *sessionManager = [[MMHTTPSessionManager alloc] initWithBaseURL:endpoint.URL sessionConfiguration:configuration serviceAdapter: serviceAdapter];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (serviceAdapter.client.securityPolicy) {
        sessionManager.securityPolicy = serviceAdapter.client.securityPolicy;
    }
    serviceAdapter.sessionManager = sessionManager;
    
    NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [backgroundConfiguration registerURLProtocolClass:[MMURLProtocol class]];
    MMHTTPSessionManager *backgroundSessionManager = [[MMHTTPSessionManager alloc] initWithBaseURL:endpoint.URL sessionConfiguration:configuration serviceAdapter: serviceAdapter];
    backgroundSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (serviceAdapter.client.securityPolicy) {
        backgroundSessionManager.securityPolicy = serviceAdapter.client.securityPolicy;
    }
    serviceAdapter.backgroundSessionManager = backgroundSessionManager;
    
    
    if (serviceAdapter.isSchemeHTTP) {
        [serviceAdapter.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:serviceAdapter.networkReachabilityStatusBlock];

        [serviceAdapter.sessionManager.reachabilityManager startMonitoring];
    }
    
    AFOAuthCredential *savedCATToken = [AFOAuthCredential retrieveCredentialWithIdentifier:[serviceAdapter CATTokenIdentifier]];
    AFOAuthCredential *savedHATToken = [AFOAuthCredential retrieveCredentialWithIdentifier:[serviceAdapter HATTokenIdentifier]];
    
    if ((!savedCATToken || savedCATToken.isExpired)) {
        [serviceAdapter authorizeApplicationWithSuccess:^(AFOAuthCredential *credential) {
            [AFOAuthCredential storeCredential:credential withIdentifier:[serviceAdapter CATTokenIdentifier]];
        } failure:^(NSError *error) {
            [AFOAuthCredential deleteCredentialWithIdentifier:[serviceAdapter CATTokenIdentifier]];
        }];
    } else {
        serviceAdapter.CATToken = savedCATToken.accessToken;
        serviceAdapter.currentCATTokenRequestStatus = MMCATTokenRequestStatusDone;
        serviceAdapter.applicationAuthenticationError = nil;
        [serviceAdapter passAppTokenToRegisteredServices];
        
        // The CAT token request returns the configuration. So, only need this call when we are using a previously saved CAT token.
        // We need to delay execution because serviceAdapter is not returned yet.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_USEC), dispatch_get_main_queue(), ^{
            
            MMConfigurationReader *reader = [[MMConfigurationReader alloc] init];
            MMCall *call = [reader getMobileConfigWithSuccess:^(NSDictionary<NSString *, NSString *> *configuration) {
                [[NSUserDefaults standardUserDefaults] setObject:configuration forKey:kMMConfigurationKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveConfigurationNotification object:self userInfo:configuration];
                if (savedHATToken) {
                    serviceAdapter.refreshToken = savedHATToken.refreshToken;
                    if (!savedHATToken.isExpired) {
                        serviceAdapter.HATToken = savedHATToken.accessToken;
                    }
//                    [serviceAdapter passUserTokenToRegisteredServices];
                }
            } failure:^(NSError *error) {
                NSDictionary *configuration = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kMMConfigurationKey];

                [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveConfigurationNotification object:self userInfo:configuration];
                if (savedHATToken) {
                    serviceAdapter.refreshToken = savedHATToken.refreshToken;
                    if (!savedHATToken.isExpired) {
                        serviceAdapter.HATToken = savedHATToken.accessToken;
                    }
                    //                    [serviceAdapter passUserTokenToRegisteredServices];
                }
            }];
            // We want this operation to finish before anything else.
            // FIXME: Git rid of this cast!
            serviceAdapter.CATTokenOperation = (Operation *)call;
            [call executeInBackground:nil];
                                                
        });
    }
    
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

- (void)authenticateApplicationWithSuccess:(void (^)())success
                                   failure:(void (^)(NSError *error))failure {
    [self authorizeApplicationWithSuccess:^(AFOAuthCredential *credential) {
        [AFOAuthCredential storeCredential:credential withIdentifier:[self CATTokenIdentifier]];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        [AFOAuthCredential deleteCredentialWithIdentifier:[self CATTokenIdentifier]];
        if (failure) {
            failure(error);
        }
    }];
}

- (void)authenticateUserWithSuccess:(void (^)())success
                            failure:(void (^)(NSError *error))failure {
    NSString *refreshToken = [AFOAuthCredential retrieveCredentialWithIdentifier:[self HATTokenIdentifier]].refreshToken;
    MMRefreshTokenRequest *refreshTokenRequest = [[MMRefreshTokenRequest alloc] init];
    refreshTokenRequest.grant_type = @"refresh_token";
    refreshTokenRequest.client_id = self.clientID;
    refreshTokenRequest.scope = @"user";
    refreshTokenRequest.refresh_token = refreshToken;
    refreshTokenRequest.device_id = [MMServiceAdapter deviceUUID];
    
    MMCall *operation = [self.userService renewAccessToken:refreshTokenRequest success:^(NSString *response) {
        NSError *jsonError;
        NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&jsonError];
        self.HATToken = responseDictionary[@"access_token"];
        [self registerCurrentDeviceWithSuccess:nil failure:nil];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self.requestOperationManager.operationQueue addOperation:operation];
}

- (void)authorizeApplicationWithSuccess:(void (^)(AFOAuthCredential *credential))success
								failure:(void (^)(NSError *error))failure {
	
	AFHTTPRequestOperation *afOperation = [self.authManager authenticateUsingOAuthWithURLString:@"com.magnet.server/applications/session" scope:@"APPLICATION" success:nil failure:nil];
	
//	// Create a NSOperationQueue here
	self.CATTokenOperation = [self.requestOperationManager requestOperationWithRequest:afOperation.request
																					  success:^(NSURLResponse *response, id responseObject) {
		AFOAuthCredential *credential;
		if (responseObject) {
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

	} failure:^(NSURLResponse *response, NSError *error) {
		self.currentCATTokenRequestStatus = MMCATTokenRequestStatusFailed;
		self.applicationAuthenticationError = error;
	}];
	[self.requestOperationManager.operationQueue addOperation:self.CATTokenOperation];
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
    if (configuration[@"mmx_app_id"] == nil) {
        configuration[@"mmx_app_id"] = jsonDictionary[@"mmx_app_id"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MMServiceAdapterDidReceiveConfigurationNotification object:self userInfo:configuration];

	AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[jsonDictionary valueForKey:@"access_token"] tokenType:[jsonDictionary valueForKey:@"token_type"]];

	//	if (refreshToken) { // refreshToken is optional in the OAuth2 spec
	//	 [credential setRefreshToken:refreshToken];
	//	}


	// Expiration is optional, but recommended in the OAuth2 spec. It not provide, assume distantFuture === never expires
	NSDate *expireDate = [NSDate distantFuture];
	id expiresIn = [jsonDictionary valueForKey:@"expires_in"];
	if (expiresIn && ![expiresIn isEqual:[NSNull null]]) {
        // Assume that the server minted the token within the last 5 minutes.
        // This is conservative.
        expireDate = [NSDate dateWithTimeIntervalSinceNow:([expiresIn doubleValue] - (5 * 60))];
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
                   rememberMe:(BOOL)rememberMe
                      success:(void (^)(BOOL successful))success
                      failure:(void (^)(NSError *error))failure {
	
    NSDictionary * params = @{@"grant_type":@"password",
							  @"username":username,
							  @"password":password,
							  @"client_id":self.clientID,
							  @"scope":@"anonymous",
                              @"remember_me": rememberMe ? @"true": @"false"};
    NSOperation *operation = [self.authManager authenticateUsingOAuthWithURLString:@"com.magnet.server/user/session" parameters:params
                                                                        success:^(AFOAuthCredential *credential) {
                                                                            if (rememberMe) {
                                                                                [AFOAuthCredential storeCredential:credential withIdentifier:[self HATTokenIdentifier]];
                                                                            }
                                                                            
                                                                            self.username = username;
                                                                            self.HATToken = credential.accessToken;
                                                                            self.refreshToken = credential.refreshToken;
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
//    NSDictionary *metaData = [[MMUserService class] metaData];
//    NSString *selectorString = NSStringFromSelector(@selector(login:username:password:client_id:scope:remember_me:mMSDEVICEID:authorization:success:failure:));
//    MMServiceMethod *method = metaData[selectorString];
    
    
    MMCall *call = [[MMCall alloc] init];
    call.serviceAdapter = self;
    call.callId = correlationId;
    call.underlyingOperation = operation;
    
    return call;
}

- (MMCall *)logoutWithSuccess:(void (^)(BOOL response))success failure:(void (^)(NSError *error))failure {
    // Unregister device
    MMCall *call = [self.deviceService unRegisterDevice:[MMServiceAdapter deviceUUID] authorization:self.HATToken success:^(BOOL response) {

    } failure:^(NSError *error) {
//        NSLog(@"Failed to unregister device when logout");
    }];
    [call executeInBackground:nil];
    
    // Delete the HAT token
    [AFOAuthCredential deleteCredentialWithIdentifier:[self HATTokenIdentifier]];

    return [self.userService logoutWithSuccess:^(BOOL response) {
        // Clean up
        self.HATToken = nil;
        self.refreshToken = nil;
        [self invalidateUserTokenInRegisteredServices];
        self.username = nil;
        
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        // Clean up
        self.HATToken = nil;
        self.refreshToken = nil;
        [self invalidateUserTokenInRegisteredServices];
        self.username = nil;
        
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
	NSString *newDeviceUUID = [[NSUUID UUID] UUIDString];
	[[NSUserDefaults standardUserDefaults] setObject:newDeviceUUID forKey:kMMDeviceUUIDKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return newDeviceUUID;
}

- (NSString *)basicAuthorization {
	NSData *nsdata = [[NSString stringWithFormat:@"%@:%@",self.clientID,self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
 
	return [NSString stringWithFormat:@"Basic %@",[nsdata base64EncodedStringWithOptions:0]];
}

#pragma mark - Overriden getters

- (AFOAuth2Manager *)authManager {
    if (!_authManager) {
        _authManager = [[AFOAuth2Manager alloc] initWithBaseURL:self.endPoint.URL
                                                       clientID:self.clientID/*kClientID*/
                                                         secret:self.clientSecret/*kClientSecret*/];
        
        [_authManager.requestSerializer setValue:[MMServiceAdapter deviceUUID] forHTTPHeaderField:@"MMS-DEVICE-ID"];
        [_authManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        _authManager.operationQueue = nil;
#pragma clang diagnostic pop
    }
    
    return _authManager;
}

- (id<MMRequestOperationManager>)requestOperationManager {
    if (!_requestOperationManager) {
        NSString *scheme = self.endPoint.URL.scheme;
        if (MMDoesSchemeHaveHTTPPrefix(scheme)) {
            MMHTTPRequestOperationManager *requestOperationManager = [[MMHTTPRequestOperationManager alloc] initWithBaseURL:self.endPoint.URL];
            requestOperationManager.manager = self.sessionManager;
            _requestOperationManager = requestOperationManager;
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

- (NSString *)CATTokenIdentifier {
    return [NSString stringWithFormat:@"%@.%@", [self appID], MMCATTokenIdentifier];
}

- (NSString *)HATTokenIdentifier {
    return [NSString stringWithFormat:@"%@.%@", [self appID], MMHATTokenIdentifier];
}

- (NSString *)appID {
    NSString *appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return appID;
}

@end
