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

#import "MMXUserQueryResponse_Private.h"
#import "DDXML.h"
#import "MMXConstants.h"
#import "MMXUserProfile_Private.h"
#import "XMPP.h"
#import "XMPPIQ.h"

@implementation MMXUserQueryResponse

+ (instancetype)responseFromIQ:(XMPPIQ *)iq {
    MMXUserQueryResponse * response = [[MMXUserQueryResponse alloc] init];
    NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement xmlns:MXnsUser];
    if (mmxElement) {
        NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
        NSError* error;
        NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (jsonDictionary[@"users"]) {
            NSArray * userArray = jsonDictionary[@"users"];
            if (userArray.count) {
                response.totalCount = [jsonDictionary[@"totalCount"] intValue];
                NSMutableArray * array = @[].mutableCopy;
                for (NSDictionary * userDict in userArray) {
                    MMXUserProfile * user = [MMXUserProfile initWithDictionary:userDict];
                    [array addObject:user];
                }
                response.users = array.copy;
            } else {
                response.totalCount = 0;
                response.users = nil;
            }
        }
    }
    return response;
}

+ (instancetype)responseWithError:(NSError *)error {
    MMXUserQueryResponse * response = [[MMXUserQueryResponse alloc] init];
    response.error = error;
    return response;
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"totalCount::%i\nusers::%@\nerror::%@\n",
                             self.totalCount, self.users, self.error.localizedDescription
                             ];
    return description;
}

@end
