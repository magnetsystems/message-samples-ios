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
 
/* A lot of code below is taken from AFNetworkActivityLogger.m */

#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import "MMXLogger.h"
#import <objc/runtime.h>

//#undef LOG_LEVEL_DEF // Undefine first only if needed
//#define LOG_LEVEL_DEF myLibLogLevel
//static const int myLibLogLevel = LOG_LEVEL_VERBOSE;

NSString * const MMXLoggingConfigKeyRollingFrequency = @"rollingFrequencyInMin";
int const MMXLoggingConfigDefaultRollingFrequency = 86400;  // 60 * 60 * 24 = one day

NSString * const MMXLoggingConfigKeyMaximumFileSize = @"maximumFileSizeInK";
int const MMXLoggingConfigDefaultMaximumFileSize = 2048;  // 2M

NSString * const MMXLoggingConfigKeyMaximumNumberOfLogFiles = @"maximumNumberOfLogFiles";
int const MMXLoggingConfigDefaultMaximumNumberOfLogFiles = 7;

static int ddLogLevel;
static DDFileLogger *fileLogger;

@interface MMXLogger ()
- (void)setupLogging;

- (void)setupTTYLogging;

@end

@implementation MMXLogger

+ (instancetype)sharedLogger {
    static MMXLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

    return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.level = MMXLoggerLevelInfo;
    self.options = MMXTTYLogging;

    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    // Stop before you start
    [self stopLogging];

    [self setupLogging];

    [self info:@"Start logging"];
}

- (void)stopLogging {
    [DDLog removeAllLoggers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self info:@"Stop logging"];
}

- (void)error:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    va_end(args);
    [self error:message args:args];
}

- (void)error:(NSString *)message args:(va_list)args {
    DDLogError(@"[ERROR] %@", [[NSString alloc] initWithFormat:message arguments:args]);
}

- (void)warn:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    va_end(args);
    [self warn:message args:args];
}

- (void)warn:(NSString *)message args:(va_list)args {
    DDLogWarn(@"[WARN] %@", [[NSString alloc] initWithFormat:message arguments:args]);
}

- (void)info:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    va_end(args);
    [self info:message args:args];
}

- (void)info:(NSString *)message args:(va_list)args {
    DDLogInfo(@"[INFO] %@", [[NSString alloc] initWithFormat:message arguments:args]);
}

- (void)debug:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    va_end(args);
    [self debug:message args:args];
}

- (void)debug:(NSString *)message args:(va_list)args {
    DDLogDebug(@"[DEBUG] %@", [[NSString alloc] initWithFormat:message arguments:args]);
}

- (void)verbose:(NSString *)message, ... {
    va_list args;
    va_start(args, message);
    va_end(args);
    [self verbose:message args:args];
}

- (void)verbose:(NSString *)message args:(va_list)args {
    DDLogVerbose(@"[VERBOSE] %@", [[NSString alloc] initWithFormat:message arguments:args]);
}

#pragma mark - Private implementation

- (void)setupLogging {
    switch (self.level) {
        case MMXLoggerLevelOff:{
            ddLogLevel = LOG_LEVEL_OFF;
            break;
        }
        case MMXLoggerLevelVerbose: {
            ddLogLevel = LOG_LEVEL_VERBOSE;
            break;
        }
        case MMXLoggerLevelDebug:{
            ddLogLevel = LOG_LEVEL_DEBUG;
            break;
        }
        case MMXLoggerLevelInfo:{
            ddLogLevel = LOG_LEVEL_INFO;
            break;
        }
        case MMXLoggerLevelWarn:{
            ddLogLevel = LOG_LEVEL_WARN;
            break;
        }
        case MMXLoggerLevelError:{
            ddLogLevel = LOG_LEVEL_ERROR;
            break;
        }
    }

    [self setupTTYLogging];

    BOOL shouldLogToFile = (self.options & MMXFileLogging);
    if(shouldLogToFile) {
        [self setupFileLogging];
    }
}

- (void)setupFileLogging {
    fileLogger = [[DDFileLogger alloc] init];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LoggingConfigurations" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:path];
    int rollingFrequency = configs[MMXLoggingConfigKeyRollingFrequency] ? [configs[MMXLoggingConfigKeyRollingFrequency] intValue] : MMXLoggingConfigDefaultRollingFrequency;
    int maxFileSize = configs[MMXLoggingConfigKeyMaximumFileSize] ? [configs[MMXLoggingConfigKeyMaximumFileSize] intValue] : MMXLoggingConfigDefaultMaximumFileSize;
    int maxFiles = configs[MMXLoggingConfigKeyMaximumNumberOfLogFiles] ? [configs[MMXLoggingConfigKeyMaximumNumberOfLogFiles] intValue] : MMXLoggingConfigDefaultMaximumNumberOfLogFiles;
    [fileLogger setRollingFrequency:rollingFrequency * 60];
    [fileLogger setMaximumFileSize:maxFileSize * 1024];
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:maxFiles];

    [DDLog addLogger:fileLogger];

    [self info:@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]];
}

- (void)setupTTYLogging {
    BOOL shouldLogToConsole = (self.options & MMXTTYLogging);
    if (shouldLogToConsole) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
}

@end
