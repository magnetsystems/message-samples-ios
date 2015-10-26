/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM(NSInteger, MMCPOperationType){
    MMCPOperationTypeRequest = 0,
    MMCPOperationTypeResponse,
    MMCPOperationTypeAckConnected,
    MMCPOperationTypeAckReceived,
};

/*
 MMCPEnvelope is an abstract superclass defining an API for other envelopes.
 It should not be instantiated directly. All subclasses should minimally override - (MMCPOperationType)operationType;
 */
@interface MMCPEnvelope : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy) NSString *requestId;

@property(nonatomic, copy) NSString *sessionId;

@property(nonatomic, readonly) MMCPOperationType operationType;

@property(nonatomic, readonly) long long timestamp;

@property(nonatomic, readonly) NSString *sender;

@end