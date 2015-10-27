/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMServiceAdapter.h"
#import <MagnetMobileServer/MagnetMobileServer-Swift.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

@class AFOAuth2Manager;
@class MMDeviceService;
@class MMUserService;
@class MMUserInfoService;

typedef void (^AFNetworkReachabilityStatusBlock)(AFNetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, MMCATTokenRequestStatus){
	MMCATTokenRequestStatusInProgress = 0,
	MMCATTokenRequestStatusDone,
	MMCATTokenRequestStatusFailed,
};

@interface MMServiceAdapter()

@property(nonatomic, assign) MMCATTokenRequestStatus currentCATTokenRequestStatus;
@property(nonatomic, strong) NSError *applicationAuthenticationError;
@property(nonatomic, strong) MMDeviceService *deviceService;
@property(nonatomic, strong) MMUserService *userService;
@property(nonatomic, strong) MMUserInfoService *userInfoService;
@property(nonatomic, strong) AFOAuth2Manager *authManager;
@property(nonatomic, copy) NSString *clientID;
@property(nonatomic, copy) NSString *clientSecret;
@property(nonatomic, copy) NSString *CATToken;
//@property(nonatomic, copy) NSString *HATToken;
@property(nonatomic, copy) NSString *mmxAppId;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSMutableDictionary *services;
@property(nonatomic, strong) NSOperation *CATTokenOperation;

@property(nonatomic, readwrite) MMDevice *currentDevice;

@property (readwrite, nonatomic, copy) AFNetworkReachabilityStatusBlock networkReachabilityStatusBlock;

- (BOOL)isSchemeHTTP;

@end