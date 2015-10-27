/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMModel.h"

#import "MMDeviceStatus.h"
#import "MMTimeUnit.h"

@interface MMClientApplication : MMModel


@property (nonatomic, copy) NSString *clientDescription;

@property (nonatomic, copy) NSString *internalId;

@property (nonatomic, assign) MMTimeUnit  expirationTimeUnit;

@property (nonatomic, copy) NSString *oauthSecret;

@property (nonatomic, assign) NSDate *createdTime;

@property (nonatomic, assign) MMDeviceStatus  clientStatus;

@property (nonatomic, assign) long long expiresIn;

@property (nonatomic, copy) NSString *clientName;

@property (nonatomic, copy) NSString *redirectUrl;

@property (nonatomic, copy) NSString *oauthClientId;

@end
