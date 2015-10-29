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
#import "MMServiceAdapter.h"
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>
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