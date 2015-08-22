//
//  MMXInviteResponse_Private.h
//  MMX
//
//  Created by Jason Ferguson on 8/20/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXInviteResponse.h"
@class MMXInternalMessageAdaptor;

@interface MMXInviteResponse ()

@property (nonatomic, readwrite) NSDate *timestamp;
@property (nonatomic, readwrite) NSString *comments;
@property (nonatomic, readwrite) MMXUser *sender;
@property (nonatomic, readwrite) MMXChannel *channel;
@property (nonatomic, readwrite) BOOL accepted;

+ (instancetype)inviteResponseFromMMXInternalMessage:(MMXInternalMessageAdaptor *)message;

@end
