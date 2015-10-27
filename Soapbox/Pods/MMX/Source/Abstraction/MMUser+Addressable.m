//
//  MMUser+Addressable.m
//  
//
//  Created by Jason Ferguson on 10/14/15.
//
//

#import "MMUser+Addressable.h"
#import "NSString+XEP_0106.h"
#import "MMXInternalAddress.h"

@implementation MMUser (Addressable)

- (MMXInternalAddress *)address {
	MMXInternalAddress *address = [MMXInternalAddress new];
	address.username = [self.userID jidEscapedString];
	return address;
}

@end
