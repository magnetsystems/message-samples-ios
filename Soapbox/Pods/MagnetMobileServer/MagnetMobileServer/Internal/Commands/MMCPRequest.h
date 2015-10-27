/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMCPCommandsEnvelope.h"
#import "MMCPPriority.h"

typedef NS_ENUM(NSInteger, MMCPExecutionType){
    MMCPExecutionTypeParallel = 0,
    MMCPExecutionTypeSequenced,
    MMCPExecutionTypePipelined,
};

@interface MMCPRequest : MMCPCommandsEnvelope

@property(nonatomic, assign) MMCPExecutionType executionType;

@property(nonatomic, assign) MMCPPriority priority;

@end