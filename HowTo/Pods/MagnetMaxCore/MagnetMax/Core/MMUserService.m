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

#import "MMUserService.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"
#import "MMPasswordResetRequest.h"
#import "MMUser.h"
#import "MMRefreshTokenRequest.h"
#import "MMUpdateProfileRequest.h"


@implementation MMUserService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method requestPasswordRest:success:failure:
        MMServiceMethod *requestPasswordRestSuccessFailure = [[MMServiceMethod alloc] init];
        requestPasswordRestSuccessFailure.path = @"com.magnet.server/user/password/reset";
        requestPasswordRestSuccessFailure.requestMethod = MMRequestMethodPOST;
        requestPasswordRestSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        requestPasswordRestSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *requestPasswordRestSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *requestPasswordRestSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        requestPasswordRestSuccessFailureParam0.name = @"body";
        requestPasswordRestSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        requestPasswordRestSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        requestPasswordRestSuccessFailureParam0.typeClass = MMPasswordResetRequest.class;
        requestPasswordRestSuccessFailureParam0.isOptional = NO;
        [requestPasswordRestSuccessFailureParams addObject:requestPasswordRestSuccessFailureParam0];

        requestPasswordRestSuccessFailure.parameters = requestPasswordRestSuccessFailureParams;
        requestPasswordRestSuccessFailure.returnType = MMServiceIOTypeBoolean;
        serviceMetaData[NSStringFromSelector(@selector(requestPasswordRest:success:failure:))] = requestPasswordRestSuccessFailure;

        // schema for service method login:username:password:client_id:scope:remember_me:mMSDEVICEID:authorization:success:failure:
        MMServiceMethod *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure = [[MMServiceMethod alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.path = @"com.magnet.server/user/session";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.requestMethod = MMRequestMethodPOST;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.consumes = [NSSet setWithObjects:@"application/x-www-form-urlencoded", nil];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0.name = @"grant_type";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam0];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1.name = @"username";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam1];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2.name = @"password";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam2];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3.name = @"client_id";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam3];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4.name = @"scope";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam4];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5.name = @"remember_me";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5.requestParameterType = MMServiceMethodParameterTypeForm;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5.type = MMServiceIOTypeBoolean;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam5];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6.name = @"MMS-DEVICE-ID";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6.requestParameterType = MMServiceMethodParameterTypeHeader;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam6];

        MMServiceMethodParameter *loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7 = [[MMServiceMethodParameter alloc] init];
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7.name = @"Authorization";
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7.requestParameterType = MMServiceMethodParameterTypeHeader;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7.type = MMServiceIOTypeString;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7.isOptional = NO;
        [loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams addObject:loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParam7];

        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.parameters = loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailureParams;
        loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure.returnType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(@selector(login:username:password:client_id:scope:remember_me:mMSDEVICEID:authorization:success:failure:))] = loginUsernamePasswordClient_idScopeRemember_meMmsdeviceidAuthorizationSuccessFailure;

        // schema for service method logoutWithSuccess:failure:
        MMServiceMethod *logoutWithSuccessFailure = [[MMServiceMethod alloc] init];
        logoutWithSuccessFailure.path = @"com.magnet.server/user/session";
        logoutWithSuccessFailure.requestMethod = MMRequestMethodDELETE;
        logoutWithSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *logoutWithSuccessFailureParams = [NSMutableArray array];
        logoutWithSuccessFailure.parameters = logoutWithSuccessFailureParams;
        logoutWithSuccessFailure.returnType = MMServiceIOTypeBoolean;
        serviceMetaData[NSStringFromSelector(@selector(logoutWithSuccess:failure:))] = logoutWithSuccessFailure;

        // schema for service method register:success:failure:
        MMServiceMethod *registerSuccessFailure = [[MMServiceMethod alloc] init];
        registerSuccessFailure.path = @"com.magnet.server/user/enrollment";
        registerSuccessFailure.requestMethod = MMRequestMethodPOST;
        registerSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        registerSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *registerSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *registerSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        registerSuccessFailureParam0.name = @"body";
        registerSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        registerSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        registerSuccessFailureParam0.typeClass = MMUser.class;
        registerSuccessFailureParam0.isOptional = NO;
        [registerSuccessFailureParams addObject:registerSuccessFailureParam0];

        registerSuccessFailure.parameters = registerSuccessFailureParams;
        registerSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        registerSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(@selector(register:success:failure:))] = registerSuccessFailure;
        
        // schema for service method searchUsers:take:skip:sort:success:failure:
        MMServiceMethod *searchUsersTakeSkipSortSuccessFailure = [[MMServiceMethod alloc] init];
        searchUsersTakeSkipSortSuccessFailure.clazz = [self class];
        searchUsersTakeSkipSortSuccessFailure.selector = @selector(searchUsers:take:skip:sort:success:failure:);
        searchUsersTakeSkipSortSuccessFailure.path = @"com.magnet.server/user/query";
        searchUsersTakeSkipSortSuccessFailure.requestMethod = MMRequestMethodGET;
        searchUsersTakeSkipSortSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *searchUsersTakeSkipSortSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *searchUsersTakeSkipSortSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        searchUsersTakeSkipSortSuccessFailureParam0.name = @"q";
        searchUsersTakeSkipSortSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeQuery;
        searchUsersTakeSkipSortSuccessFailureParam0.type = MMServiceIOTypeString;
        searchUsersTakeSkipSortSuccessFailureParam0.isOptional = NO;
        [searchUsersTakeSkipSortSuccessFailureParams addObject:searchUsersTakeSkipSortSuccessFailureParam0];
        
        MMServiceMethodParameter *searchUsersTakeSkipSortSuccessFailureParam1 = [[MMServiceMethodParameter alloc] init];
        searchUsersTakeSkipSortSuccessFailureParam1.name = @"take";
        searchUsersTakeSkipSortSuccessFailureParam1.requestParameterType = MMServiceMethodParameterTypeQuery;
        searchUsersTakeSkipSortSuccessFailureParam1.type = MMServiceIOTypeInteger;
        searchUsersTakeSkipSortSuccessFailureParam1.isOptional = NO;
        [searchUsersTakeSkipSortSuccessFailureParams addObject:searchUsersTakeSkipSortSuccessFailureParam1];
        
        MMServiceMethodParameter *searchUsersTakeSkipSortSuccessFailureParam2 = [[MMServiceMethodParameter alloc] init];
        searchUsersTakeSkipSortSuccessFailureParam2.name = @"skip";
        searchUsersTakeSkipSortSuccessFailureParam2.requestParameterType = MMServiceMethodParameterTypeQuery;
        searchUsersTakeSkipSortSuccessFailureParam2.type = MMServiceIOTypeInteger;
        searchUsersTakeSkipSortSuccessFailureParam2.isOptional = NO;
        [searchUsersTakeSkipSortSuccessFailureParams addObject:searchUsersTakeSkipSortSuccessFailureParam2];
        
        MMServiceMethodParameter *searchUsersTakeSkipSortSuccessFailureParam3 = [[MMServiceMethodParameter alloc] init];
        searchUsersTakeSkipSortSuccessFailureParam3.name = @"sort";
        searchUsersTakeSkipSortSuccessFailureParam3.requestParameterType = MMServiceMethodParameterTypeQuery;
        searchUsersTakeSkipSortSuccessFailureParam3.type = MMServiceIOTypeString;
        searchUsersTakeSkipSortSuccessFailureParam3.isOptional = NO;
        [searchUsersTakeSkipSortSuccessFailureParams addObject:searchUsersTakeSkipSortSuccessFailureParam3];
        
        searchUsersTakeSkipSortSuccessFailure.parameters = searchUsersTakeSkipSortSuccessFailureParams;
        searchUsersTakeSkipSortSuccessFailure.returnType = MMServiceIOTypeArray;
        searchUsersTakeSkipSortSuccessFailure.returnComponentType = MMServiceIOTypeMagnetNode;
        searchUsersTakeSkipSortSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(searchUsersTakeSkipSortSuccessFailure.selector)] = searchUsersTakeSkipSortSuccessFailure;
        
        // schema for service method getUsersByUserNames:success:failure:
        MMServiceMethod *getUsersByUserNamesSuccessFailure = [[MMServiceMethod alloc] init];
        getUsersByUserNamesSuccessFailure.clazz = [self class];
        getUsersByUserNamesSuccessFailure.selector = @selector(getUsersByUserNames:success:failure:);
        getUsersByUserNamesSuccessFailure.path = @"com.magnet.server/user/users";
        getUsersByUserNamesSuccessFailure.requestMethod = MMRequestMethodGET;
        getUsersByUserNamesSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getUsersByUserNamesSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getUsersByUserNamesSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getUsersByUserNamesSuccessFailureParam0.name = @"userNames";
        getUsersByUserNamesSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeQuery;
        getUsersByUserNamesSuccessFailureParam0.type = MMServiceIOTypeArray;
        getUsersByUserNamesSuccessFailureParam0.componentType = MMServiceIOTypeString;
        getUsersByUserNamesSuccessFailureParam0.isOptional = NO;
        [getUsersByUserNamesSuccessFailureParams addObject:getUsersByUserNamesSuccessFailureParam0];
        
        getUsersByUserNamesSuccessFailure.parameters = getUsersByUserNamesSuccessFailureParams;
        getUsersByUserNamesSuccessFailure.returnType = MMServiceIOTypeArray;
        getUsersByUserNamesSuccessFailure.returnComponentType = MMServiceIOTypeMagnetNode;
        getUsersByUserNamesSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(getUsersByUserNamesSuccessFailure.selector)] = getUsersByUserNamesSuccessFailure;
        
        // schema for service method getUsersByUserIds:success:failure:
        MMServiceMethod *getUsersByUserIdsSuccessFailure = [[MMServiceMethod alloc] init];
        getUsersByUserIdsSuccessFailure.clazz = [self class];
        getUsersByUserIdsSuccessFailure.selector = @selector(getUsersByUserIds:success:failure:);
        getUsersByUserIdsSuccessFailure.path = @"com.magnet.server/user/users/ids";
        getUsersByUserIdsSuccessFailure.requestMethod = MMRequestMethodGET;
        getUsersByUserIdsSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *getUsersByUserIdsSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *getUsersByUserIdsSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        getUsersByUserIdsSuccessFailureParam0.name = @"userIds";
        getUsersByUserIdsSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeQuery;
        getUsersByUserIdsSuccessFailureParam0.type = MMServiceIOTypeArray;
        getUsersByUserIdsSuccessFailureParam0.componentType = MMServiceIOTypeString;
        getUsersByUserIdsSuccessFailureParam0.isOptional = NO;
        [getUsersByUserIdsSuccessFailureParams addObject:getUsersByUserIdsSuccessFailureParam0];
        
        getUsersByUserIdsSuccessFailure.parameters = getUsersByUserIdsSuccessFailureParams;
        getUsersByUserIdsSuccessFailure.returnType = MMServiceIOTypeArray;
        getUsersByUserIdsSuccessFailure.returnComponentType = MMServiceIOTypeMagnetNode;
        getUsersByUserIdsSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(getUsersByUserIdsSuccessFailure.selector)] = getUsersByUserIdsSuccessFailure;
        
        // schema for service method renewAccessToken:success:failure:
        MMServiceMethod *renewAccessTokenSuccessFailure = [[MMServiceMethod alloc] init];
        renewAccessTokenSuccessFailure.clazz = [self class];
        renewAccessTokenSuccessFailure.selector = @selector(renewAccessToken:success:failure:);
        renewAccessTokenSuccessFailure.path = @"com.magnet.server/user/newtoken";
        renewAccessTokenSuccessFailure.requestMethod = MMRequestMethodPOST;
        renewAccessTokenSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *renewAccessTokenSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *renewAccessTokenSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        renewAccessTokenSuccessFailureParam0.name = @"body";
        renewAccessTokenSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        renewAccessTokenSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        renewAccessTokenSuccessFailureParam0.typeClass = MMRefreshTokenRequest.class;
        renewAccessTokenSuccessFailureParam0.isOptional = NO;
        [renewAccessTokenSuccessFailureParams addObject:renewAccessTokenSuccessFailureParam0];
        
        renewAccessTokenSuccessFailure.parameters = renewAccessTokenSuccessFailureParams;
        renewAccessTokenSuccessFailure.returnType = MMServiceIOTypeString;
        serviceMetaData[NSStringFromSelector(renewAccessTokenSuccessFailure.selector)] = renewAccessTokenSuccessFailure;
        
        // schema for service method updateProfile:success:failure:
        MMServiceMethod *updateProfileSuccessFailure = [[MMServiceMethod alloc] init];
        updateProfileSuccessFailure.clazz = [self class];
        updateProfileSuccessFailure.selector = @selector(updateProfile:success:failure:);
        updateProfileSuccessFailure.path = @"com.magnet.server/user/profile";
        updateProfileSuccessFailure.requestMethod = MMRequestMethodPUT;
        updateProfileSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        updateProfileSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];
        
        NSMutableArray *updateProfileSuccessFailureParams = [NSMutableArray array];
        MMServiceMethodParameter *updateProfileSuccessFailureParam0 = [[MMServiceMethodParameter alloc] init];
        updateProfileSuccessFailureParam0.name = @"body";
        updateProfileSuccessFailureParam0.requestParameterType = MMServiceMethodParameterTypeBody;
        updateProfileSuccessFailureParam0.type = MMServiceIOTypeMagnetNode;
        updateProfileSuccessFailureParam0.typeClass = MMUpdateProfileRequest.class;
        updateProfileSuccessFailureParam0.isOptional = NO;
        [updateProfileSuccessFailureParams addObject:updateProfileSuccessFailureParam0];
        
        updateProfileSuccessFailure.parameters = updateProfileSuccessFailureParams;
        updateProfileSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        updateProfileSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(updateProfileSuccessFailure.selector)] = updateProfileSuccessFailure;

        
        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
