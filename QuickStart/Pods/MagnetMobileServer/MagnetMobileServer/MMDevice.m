/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMDevice.h"

@implementation MMDevice

+ (NSDictionary *)attributeMappings {
    NSDictionary *dictionary = @{
                                 @"userID": @"userId",
                                 @"deviceID": @"deviceId",
                                 };
    NSMutableDictionary *attributeMappings = [[super attributeMappings] mutableCopy];
    [attributeMappings addEntriesFromDictionary:dictionary];
    
    return attributeMappings;
}

+ (NSDictionary *)listAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [dictionary addEntriesFromDictionary:[super listAttributeTypes]];
    return dictionary;
}

+ (NSDictionary *)mapAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [dictionary addEntriesFromDictionary:[super mapAttributeTypes]];
    return dictionary;
}

+ (NSDictionary *)enumAttributeTypes {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"deviceStatus" : MMDeviceStatusContainer.class,
        @"os" : MMOsTypeContainer.class,
        @"pushAuthority" : MMPushAuthorityTypeContainer.class,
    }];
    [dictionary addEntriesFromDictionary:[super enumAttributeTypes]];
    return dictionary;
}

+ (NSArray *)charAttributes {
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[
    ]];
    [array addObjectsFromArray:[super charAttributes]];
    return array;
}

@end
