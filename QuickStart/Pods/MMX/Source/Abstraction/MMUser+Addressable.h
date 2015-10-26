//
//  MMUser+Addressable.h
//  
//
//  Created by Jason Ferguson on 10/14/15.
//
//

#import <MagnetMobileServer/MagnetMobileServer.h>
#import "MMXAddressable.h"

@interface MMUser (Addressable) <MMXAddressable>

//MMXAddressable Protocol
@property (nonatomic, readonly) MMXInternalAddress *address;

@end
