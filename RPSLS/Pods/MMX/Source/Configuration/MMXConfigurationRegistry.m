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

#import "MMXConfigurationRegistry.h"
#import "MMXLogger.h"


@implementation MMXConfigurationRegistry

+ (NSDictionary *)sharedConfigurationRegistry {
    static NSDictionary *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MMXLogger sharedLogger] verbose:@"Reading settings from Configurations.plist"];

        _sharedConfiguration = [NSDictionary dictionaryWithContentsOfFile:[MMXConfigurationRegistry pathForConfiguration]];
    });

    return _sharedConfiguration;
}

+(NSString *)pathForConfiguration{
    NSString *filename = @"Configurations";
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"plist"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!exists) {
        //Try to fallover to mainBundle
        path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];

        exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (!exists) {
            NSAssert(exists, @"You must include your Configurations.plist file in the project. You can download this file on the Settings page of the Magnet Message Web Interface");
        }
    }
    return path;
}

@end