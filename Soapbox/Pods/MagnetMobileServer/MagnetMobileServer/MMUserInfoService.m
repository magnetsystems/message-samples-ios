/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMUserInfoService.h"
#import "MMServiceMethod.h"
#import "MMServiceMethodParameter.h"
#import "MMUser.h"

@implementation MMUserInfoService

+ (NSDictionary *)metaData {
    static NSDictionary *__metaData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *serviceMetaData = [NSMutableDictionary dictionary];


        // schema for service method getUserInfoWithSuccess:failure:
        MMServiceMethod *getUserInfoWithSuccessFailure = [[MMServiceMethod alloc] init];
        getUserInfoWithSuccessFailure.path = @"com.magnet.server/userinfo";
        getUserInfoWithSuccessFailure.requestMethod = MMRequestMethodGET;
        getUserInfoWithSuccessFailure.consumes = [NSSet setWithObjects:@"application/json", nil];
        getUserInfoWithSuccessFailure.produces = [NSSet setWithObjects:@"application/json", nil];

        NSMutableArray *getUserInfoWithSuccessFailureParams = [NSMutableArray array];
        getUserInfoWithSuccessFailure.parameters = getUserInfoWithSuccessFailureParams;
        getUserInfoWithSuccessFailure.returnType = MMServiceIOTypeMagnetNode;
        getUserInfoWithSuccessFailure.returnTypeClass = MMUser.class;
        serviceMetaData[NSStringFromSelector(@selector(getUserInfoWithSuccess:failure:))] = getUserInfoWithSuccessFailure;


        __metaData = serviceMetaData;
    });

    return __metaData;
}

@end
