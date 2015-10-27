/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMModel.h"


@interface MMClientRegistrationRequest : MMModel


@property (nonatomic, copy) NSString *tag;

@property (nonatomic, copy) NSString *client_description;

@property (nonatomic, copy) NSString *client_name;

@property (nonatomic, copy) NSString *password;

@end
