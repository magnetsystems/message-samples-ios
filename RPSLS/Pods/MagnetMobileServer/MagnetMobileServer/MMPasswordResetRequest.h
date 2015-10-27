/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */


#import "MMModel.h"
#import "MMPasswordResetMethod.h"


@interface MMPasswordResetRequest : MMModel


@property (nonatomic, assign) MMPasswordResetMethod passwordResetMethod;

@property (nonatomic, copy) NSString *theNewPassword;

@property (nonatomic, copy) NSString *otpCode;

@property (nonatomic, copy) NSDictionary *challengeResponses;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *oldPassword;

@property (nonatomic, copy) NSString *client_description;

@end
