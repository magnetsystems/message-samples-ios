//
// Created by Jim Liu on 8/3/15.
// Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "DDLogFileManagerDefaultWIthRemote.h"
#import "MMLogEventsCollectionService.h"
#import "MMData.h"
#import "MMCall.h"


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