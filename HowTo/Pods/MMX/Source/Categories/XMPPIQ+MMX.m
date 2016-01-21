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

#import "XMPPIQ+MMX.h"
#import "XMPP.h"
#import "MMXConstants.h"

@implementation XMPPIQ (MMX)

- (NSError *)errorWithTitle:(NSString *)title {
	NSXMLElement *mmxElement = [self elementForName:MXmmxElement];
	NSXMLElement *errorElement = [self elementForName:@"error"];
    if (mmxElement) {
        NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
        NSError* error;
        NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            return [self errorFromCode:[jsonDictionary[@"code"] intValue] withTitle:title message:jsonDictionary[@"message"]];
        } else {
            return error;
        }
	} else if (errorElement) {
		int code = [[[errorElement attributeForName:@"code"] stringValue] intValue];
		NSXMLNode * errorNode = [errorElement childAtIndex:0];
		NSString * errorName = [errorNode name];
		return [self errorFromCode:code withTitle:title message:errorName];
	}
    return [self errorFromCode:0 withTitle:title message:@"An unknown error occured."];
}

- (NSError *)errorFromCode:(int)code withTitle:(NSString *)title message:(NSString *)message {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(title, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, nil),
                               };
    NSError *error = [NSError errorWithDomain:MMXErrorDomain
                                         code:code
                                     userInfo:userInfo];

    return error;
}

@end
