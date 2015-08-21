//
//  MMXInternalAddress.m
//  MMX
//
//  Created by Jason Ferguson on 8/19/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXInternalAddress.h"
#import "MMXConstants.h"

@implementation MMXInternalAddress

- (NSDictionary *)asDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (self.username == nil) {
		return nil;
	}
	[dict setObject:self.username.copy forKey:kAddressUsernameKey];
	if (self.deviceID) {
		[dict setObject:self.deviceID.copy forKey:kAddressDeviceIDKey];
	}
	if (self.displayName) {
		[dict setObject:self.displayName.copy forKey:kAddressDisplayNameKey];
	}
	return dict.copy;
}
@end
