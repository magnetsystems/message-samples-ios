/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMCPEnvelope.h"

/*
 MMCPCommandsEnvelope is an abstract superclass defining an API for other command envelopes.
 It should not be instantiated directly.
 */
@interface MMCPCommandsEnvelope : MMCPEnvelope

@property(nonatomic, copy) NSArray *commands;

@end