/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMModel.h"


@interface MMLogEvent : MMModel


@property (nonatomic, copy) NSArray *tags;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *correlationId;

@property (nonatomic, assign) long long utctime;

@property (nonatomic, copy) NSString *location;

@property (nonatomic, copy) NSString *subcategory;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSDictionary *payload;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *identifier;

@end
