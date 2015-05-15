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

#import "MMXRemoteNotification.h"


NSString *const kMMXRemoteNotificationTypeKey = @"ty";
NSString *const kMMXRemoteNotificationCallbackURLKey = @"cu";
NSString *const kMMXRemoteNotificationWakeupType = @"mmx:w:retrieve";
NSString *const kMMXRemoteNotificationPushType = @"mmx:p:";
NSString *const kMMXRemoteNotificationFrameworkKey = @"_mmx";

@implementation MMXRemoteNotification

+ (BOOL)isMMXRemoteNotification:(NSDictionary *)userInfo {
    return (userInfo[kMMXRemoteNotificationFrameworkKey] != nil);
}

+ (BOOL)isWakeupRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *mmxDictionary = userInfo[kMMXRemoteNotificationFrameworkKey];
    return [mmxDictionary[kMMXRemoteNotificationTypeKey] isEqualToString:kMMXRemoteNotificationWakeupType];
}

+ (void)acknowledgeRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL success))completion {
    NSDictionary *mmxDictionary = userInfo[kMMXRemoteNotificationFrameworkKey];
    if ([mmxDictionary[kMMXRemoteNotificationTypeKey] isEqualToString:kMMXRemoteNotificationPushType]) {
        NSString *callbackURLString = mmxDictionary[kMMXRemoteNotificationCallbackURLKey];
        NSURL *callbackURL = [NSURL URLWithString:callbackURLString];
        if (callbackURL) {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:callbackURL];
            request.HTTPMethod = @"POST";
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
                                           ^(NSURLResponse *response, NSData *data, NSError *error)
                                           {
                                               if (completion) {
                                                   completion(error == nil);
                                               }
                                           }];
        } else {
            if (completion) {
                completion(NO);
            }
        }

    } else {
        if (completion) {
            completion(NO);
        }
    }
}


@end