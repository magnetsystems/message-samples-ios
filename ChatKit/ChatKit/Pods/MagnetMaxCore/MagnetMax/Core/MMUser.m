/*
 * Copyright (c) 2015 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "MMUser.h"
@implementation MMUser

+ (NSDictionary *)attributeMappings {
    NSDictionary *dictionary = @{
                                 @"userID": @"userIdentifier",
                                 @"extras": @"userAccountData",
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
        @"userRealm" : MMUserRealmContainer.class,
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

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.roles forKey:@"roles"];
    [encoder encodeObject:@(self.userRealm) forKey:@"userRealm"];
    [encoder encodeObject:self.extras forKey:@"extras"];
    [encoder encodeObject:self.tags forKey:@"tags"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.roles = [decoder decodeObjectForKey:@"roles"];
        self.userRealm = (MMUserRealm)[[decoder decodeObjectForKey:@"userRealm"] integerValue];
        self.extras = [decoder decodeObjectForKey:@"extras"];
        self.tags = [decoder decodeObjectForKey:@"tags"];
    }
    return self;
}

#pragma mark - Overriden getters

//- (NSDictionary <NSString *, NSString *>*)extras {
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_extras];
//    [dict removeObjectForKey:@"hasAvatar"];
//
//    return [dict copy];
//}

@end
