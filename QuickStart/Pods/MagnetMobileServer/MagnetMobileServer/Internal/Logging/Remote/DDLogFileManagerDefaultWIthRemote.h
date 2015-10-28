/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDFileLogger.h>

@class MMLogEventsCollectionService;


@interface DDLogFileManagerDefaultWIthRemote : DDLogFileManagerDefault

@property (nonatomic, strong) MMLogEventsCollectionService *remoteLoggingService;

@property (nonatomic) BOOL localFileLoggingEnabled;

@property (nonatomic) BOOL remoteFileLoggingEnabled;

@end