/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMClientApplication.h"
@implementation MMClientApplication

+ (NSDictionary *)attributeMappings {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [dictionary addEntriesFromDictionary:[super attributeMappings]];
    return dictionary;
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
        @"clientStatus" : MMDeviceStatusContainer.class,
        @"expirationTimeUnit" : MMTimeUnitContainer.class,
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
