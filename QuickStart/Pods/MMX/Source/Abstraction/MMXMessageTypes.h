//
//  MMXMessageTypes.h
//  MMX
//
//  Created by Jason Ferguson on 8/10/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

/**
 *  Values representing the connection status of the MMXClient.
 */
typedef NS_ENUM(NSUInteger, MMXMessageType){
	/**
	 *  Typical user to user(s) message.
	 */
	MMXMessageTypeDefault = 0,
	/**
	 *  Message that was published to a channel.
	 */
	MMXMessageTypeChannel,
};
