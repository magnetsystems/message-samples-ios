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


#import "MMXDeviceQueryResponse.h"
#import "MMXDeviceProfile_Private.h"
#import "DDXML.h"
#import "MMXConstants.h"
#import "XMPP.h"

@implementation MMXDeviceQueryResponse

+ (instancetype)responseFromIQ:(XMPPIQ *)iq username:(NSString *)username {
    
    MMXDeviceQueryResponse * response = [[MMXDeviceQueryResponse alloc] init];
    NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement];
    if (mmxElement) {
        NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
        NSError* error;
        NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        id parsedJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        if (!error) {
            if ([parsedJson isKindOfClass:[NSArray class]]) {
                NSMutableArray * deviceArray = @[].mutableCopy;
                for (NSDictionary * dict in (NSArray *)parsedJson) {
                    if (dict) {
                        MMXDeviceProfile * device = [MMXDeviceProfile deviceFromResponseDictionary:dict username:username];
                        if (device) {
                            [deviceArray addObject:device];
                        }
                    }
                }
                if (deviceArray.count) {
                    response.devices = deviceArray.copy;
                } else {
                    response.devices = @[];
                }
                response.code = 200;
                response.message = @"Successfully received devices.";

            } else if ([parsedJson isKindOfClass:[NSDictionary class]]){
                NSDictionary * dict = parsedJson;
                if (dict[@"code"]) {
                    response.code = [dict[@"code"] intValue];
                    response.message = dict[@"message"];
                }
            } else {
                response.code = 500;
                response.message = @"An unknown error occured";
            }
        } else {
            response.code = 0;
            response.message = @"An unknown error occured";
        }
    }
    return response;
}

- (NSError *)unknownError {
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"An unknown error occured", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An unknown error occured", nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:500
                                     userInfo:userInfo];
    return error;
    
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"topics::%@\ncode::%i\nmessage::%@\n",
                             self.devices, self.code, self.message
                             ];
    return description;
}

- (NSError *)errorFromResponse:(NSString *)description {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(self.message, nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:self.code
                                     userInfo:userInfo];
    return error;
}

@end
