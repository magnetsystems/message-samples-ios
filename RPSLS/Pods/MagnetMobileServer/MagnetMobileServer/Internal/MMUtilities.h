/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MMServiceIOType.h"


@interface MMUtilities : NSObject

+ (MMServiceIOType)serviceTypeForClass:(Class)clazz;

@end