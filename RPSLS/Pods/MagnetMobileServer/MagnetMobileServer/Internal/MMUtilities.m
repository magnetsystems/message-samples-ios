/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMUtilities.h"
#import "MMEnumAttributeContainer.h"
#import "MMModel.h"


@implementation MMUtilities

+ (MMServiceIOType)serviceTypeForClass:(Class)clazz {

    MMServiceIOType serviceType = MMServiceIOTypeVoid;

    if ([clazz conformsToProtocol:@protocol(MMEnumAttributeContainer)]) {
        serviceType = MMServiceIOTypeEnum;
    } else if ([clazz isSubclassOfClass:MMModel.class]) {
        serviceType = MMServiceIOTypeMagnetNode;
    }
    return serviceType;
}

@end