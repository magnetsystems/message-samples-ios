//
//  MagnetMessage.m
//  QuickStart
//
//  Created by Jason Ferguson on 8/5/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MagnetMessage.h"
#import "MagnetDelegate.h"
#import "MMX.h"

@implementation MagnetMessage

+ (void)startSession {
	[[MagnetDelegate sharedDelegate] startMMXClient];
}

+ (void)endSession {
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated ||
		[MMXClient sharedClient].connectionStatus == MMXConnectionStatusConnected) {
		[[MMXClient sharedClient] disconnect];
	}
}

@end
