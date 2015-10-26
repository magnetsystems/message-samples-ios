/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMCPResponse.h"


@implementation MMCPResponse

#pragma mark - Overriden getters

- (MMCPOperationType)operationType {
    return MMCPOperationTypeResponse;
}


@end