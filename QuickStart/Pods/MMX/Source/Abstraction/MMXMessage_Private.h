//
//  MMXMessage_Private.h
//  QuickStart
//
//  Created by Jason Ferguson on 8/5/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXMessage.h"

@interface MMXMessage ()

@property (nonatomic, readwrite) MMXMessageType messageType;

@property(nonatomic, readwrite) NSString *messageID;

@property(nonatomic, readwrite) NSDate *timestamp;

@property(nonatomic, readwrite) MMXUser *sender;

@property (nonatomic, readwrite) MMXChannel *channel;

@property(nonatomic, readwrite) NSSet *recipients;

@property(nonatomic, readwrite) NSDictionary *messageContent;

- (NSArray *)recipientsForOutboundMessage;

@end