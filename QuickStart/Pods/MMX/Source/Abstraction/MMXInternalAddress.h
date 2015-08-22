//
//  MMXInternalAddress.h
//  MMX
//
//  Created by Jason Ferguson on 8/19/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface MMXInternalAddress : MTLModel

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *displayName;

- (NSDictionary *)asDictionary;

@end
