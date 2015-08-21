//
//  MMXInviteResponse.h
//  MMX
//
//  Created by Jason Ferguson on 8/20/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MTLModel.h"
@class MMXUser;
@class MMXChannel;

@interface MMXInviteResponse : MTLModel

/**
 *  Time the response was sent
 */
@property (nonatomic, readonly) NSDate *timestamp;

/**
 *  A custom message from the sender
 */
@property (nonatomic, readonly) NSString *textMessage;

/**
 *  The user that sent the response
 */
@property (nonatomic, readonly) MMXUser *sender;

/**
 *  The channel the invite is for.
 */
@property (nonatomic, readonly) MMXChannel *channel;

/**
 *  The response to the invite.
 */
@property (nonatomic, readonly) BOOL accepted;

@end
