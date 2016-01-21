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

#import "DDLogFileManagerDefaultWIthRemote.h"
#import "MMLogEventsCollectionService.h"
#import "MMData.h"
#import <MagnetMaxCore/MagnetMaxCore-Swift.h>


@implementation DDLogFileManagerDefaultWIthRemote

-(void)didArchiveLogFile:(NSString *)logFilePath {
    [self uploadFileToServer:logFilePath];
}

-(void)didRollAndArchiveLogFile:(NSString *)logFilePath {
    NSLog(@"didRollAndArchiveLogFile called : %@", logFilePath);
    [self uploadFileToServer:logFilePath];
}

-(void) uploadFileToServer:(NSString *) logFilePath {
    if (!self.remoteFileLoggingEnabled) {
        return;
    }

    MMData *data = [[MMData alloc] init];
    data.binaryData = [[NSFileManager defaultManager] contentsAtPath:logFilePath];
    data.name = @"file";

    MMCall *call = [self.remoteLoggingService addEventsFromFile:data success:^{
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
        NSLog(@"Log file deleted after uploading to server : %@", logFilePath);
    }                                                   failure:^(NSError *error) {
        NSLog(@"Failed to upload log file %@ to server due to : %@", logFilePath, error);
    }];

    [call executeInBackground:nil];
}

@end