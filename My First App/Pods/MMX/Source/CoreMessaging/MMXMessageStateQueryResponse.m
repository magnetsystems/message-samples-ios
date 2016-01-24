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

#import "MMXMessageStateQueryResponse_Private.h"
#import "DDXML.h"
#import "MMXConstants.h"
#import "XMPP.h"
#import "XMPPIQ.h"

@implementation MMXMessageStateQueryResponse


+ (instancetype)initWithIQ:(XMPPIQ *)iq {

    MMXMessageStateQueryResponse * response = [[MMXMessageStateQueryResponse alloc] init];

    if (response) {
        NSXMLElement *mmxElement = [iq elementForName:MXmmxElement];
        if (mmxElement) {
            NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
            NSError* error;
            NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if (!error) {
                response.queryResult = jsonDictionary;
            }
            //FIXME: Need to express to the developer that a parsing error occured
        }
    }
    return response;
}

@end
