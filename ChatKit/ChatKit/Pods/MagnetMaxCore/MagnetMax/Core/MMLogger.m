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


#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDLogMacros.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import "MMLogger.h"
#import "MMServiceAdapter.h"
#import "AFURLConnectionOperation.h"
#import "AFURLSessionManager.h"
#import "MMLogEvent.h"
#import "MMLogEventFormatter.h"
#import "DDLogFileManagerDefaultWIthRemote.h"
#import "MMLogEventsCollectionService.h"
#import <objc/runtime.h>

//#undef LOG_LEVEL_DEF // Undefine first only if needed
//#define LOG_LEVEL_DEF myLibLogLevel
//static const int myLibLogLevel = LOG_LEVEL_VERBOSE;

NSString * const MMLoggingConfigKeyRollingFrequency = @"rollingFrequencyInMin";
int const MMLoggingConfigDefaultRollingFrequency = 86400;  // 60 * 60 * 24 = one day

NSString * const MMLoggingConfigKeyMaximumFileSize = @"maximumFileSizeInK";
int const MMLoggingConfigDefaultMaximumFileSize = 2048;  // 2M

NSString * const MMLoggingConfigKeyMaximumNumberOfLogFiles = @"maximumNumberOfLogFiles";
int const MMLoggingConfigDefaultMaximumNumberOfLogFiles = 7;

static DDLogLevel ddLogLevel;
static DDFileLogger *fileLogger;

static NSString *message = @"__log_event__";

static NSURLRequest * AFNetworkRequestFromNotification(NSNotification *notification) {
    NSURLRequest *request = nil;
    if ([[notification object] isKindOfClass:[AFURLConnectionOperation class]]) {
        request = [(AFURLConnectionOperation *)[notification object] request];
    } else if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        request = [[notification object] originalRequest];
    }

    return request;
}

@interface MMLogger ()
- (void)setupLogging;

- (void)setupFileLoggingWithRemoteBackup:(MMServiceAdapter *)serviceAdapter localFileEnalbed:(BOOL) localFileEnalbed;

- (void)setupTTYLogging;

@end

@implementation MMLogger

+ (instancetype)sharedLogger {
    static MMLogger *_sharedLogger = nil;

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

    self.level = MMLoggerLevelInfo;
    self.options = MMTTYLogging;

    return self;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)startLogging {
    // Stop before you start
    [self stopLogging];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
#endif
    
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

- (void)log:(MMLoggerLevel)level message:(NSString *)message args:(va_list)args {
    LOG_MAYBE(YES, ddLogLevel, [self convertDDLLogFlag:level], 0, nil, __PRETTY_FUNCTION__, message, args);
}

- (void)logEvent:(MMLogEvent *) event {
    LOG_MAYBE(YES, DDLogLevelAll, [self convertDDLLogFlag:self.level], 0, event, __PRETTY_FUNCTION__, message, nil);
}

-(void)flushLogging {
    if(nil != fileLogger && (self.options & MMRemoteLogging)) {
        [fileLogger rollLogFileWithCompletionBlock:^{
            [self info:@"Logging file rolled by flushLogging"];
        }];
    }
}

#pragma mark - Private implementation

- (void)setupLogging {
    ddLogLevel = [self convertLogLevel:self.level];

    [self setupTTYLogging];

    BOOL shouldLogToFile = (self.options & MMFileLogging);
    BOOL shouldLogToRemote = (self.options & MMRemoteLogging);
    if(shouldLogToRemote) {
      if(nil != self.serviceAdapter) {
          [self setupFileLoggingWithRemoteBackup:[self.serviceAdapter createService:[MMLogEventsCollectionService class]] localFileEnalbed:shouldLogToFile];
      } else {
          NSLog(@"remoteServerConfig shouldn't be nil when MMRemoteLogging is enabled.");
      }
    } else if(shouldLogToFile) {
        [self setupFileLogging];
    }
}

- (DDLogLevel) convertLogLevel:(MMLoggerLevel) level {
    DDLogLevel logLevel;
    switch (level) {
        case MMLoggerLevelOff:{
            logLevel = DDLogLevelOff;
            break;
        }
        case MMLoggerLevelVerbose: {
            logLevel = DDLogLevelVerbose;
            break;
        }
        case MMLoggerLevelDebug:{
            logLevel = DDLogLevelDebug;
            break;
        }
        case MMLoggerLevelInfo:{
            logLevel = DDLogLevelInfo;
            break;
        }
        case MMLoggerLevelWarn:{
            logLevel = DDLogLevelWarning;
            break;
        }
        case MMLoggerLevelError:{
            logLevel = DDLogLevelError;
            break;
        }
    }

    return logLevel;
}

- (DDLogFlag) convertDDLLogFlag:(MMLoggerLevel) level {
    DDLogFlag logFlag;
    switch (level) {
        case MMLoggerLevelOff:{
            logFlag = DDLogFlagError;
            break;
        }
        case MMLoggerLevelVerbose: {
            logFlag = DDLogFlagVerbose;
            break;
        }
        case MMLoggerLevelDebug:{
            logFlag = DDLogFlagDebug;
            break;
        }
        case MMLoggerLevelInfo:{
            logFlag = DDLogFlagInfo;
            break;
        }
        case MMLoggerLevelWarn:{
            logFlag = DDLogFlagWarning;
            break;
        }
        case MMLoggerLevelError:{
            logFlag = DDLogFlagError;
            break;
        }
    }

    return logFlag;
}

- (void)setupFileLogging {
    [self setupFileLoggingWithRemoteBackup:nil localFileEnalbed:YES];
}

- (void)setupFileLoggingWithRemoteBackup:(MMLogEventsCollectionService *)logEventsCollectionService localFileEnalbed:(BOOL) localFileEnalbed {
    if(nil == logEventsCollectionService) {
        fileLogger = [[DDFileLogger alloc] init];
    } else {
        DDLogFileManagerDefaultWIthRemote *remoteFileManager = [[DDLogFileManagerDefaultWIthRemote alloc] init];
        remoteFileManager.remoteFileLoggingEnabled = YES;
        remoteFileManager.localFileLoggingEnabled = localFileEnalbed;
        remoteFileManager.remoteLoggingService = logEventsCollectionService;
        fileLogger = [[DDFileLogger alloc] initWithLogFileManager:remoteFileManager];
        fileLogger.logFormatter = [[MMLogEventFormatter alloc] init];
    }

    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LoggingConfigurations" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:path];
    int rollingFrequency = configs[MMLoggingConfigKeyRollingFrequency] ? [configs[MMLoggingConfigKeyRollingFrequency] intValue] : MMLoggingConfigDefaultRollingFrequency;
    int maxFileSize = configs[MMLoggingConfigKeyMaximumFileSize] ? [configs[MMLoggingConfigKeyMaximumFileSize] intValue] : MMLoggingConfigDefaultMaximumFileSize;
    int maxFiles = configs[MMLoggingConfigKeyMaximumNumberOfLogFiles] ? [configs[MMLoggingConfigKeyMaximumNumberOfLogFiles] intValue] : MMLoggingConfigDefaultMaximumNumberOfLogFiles;
    [fileLogger setRollingFrequency:rollingFrequency * 60];
    [fileLogger setMaximumFileSize:maxFileSize * 1024];
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:maxFiles];

    [DDLog addLogger:fileLogger];

    [self info:@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]];
}

- (void)setupTTYLogging {
    BOOL shouldLogToConsole = (self.options & MMTTYLogging);
    if (shouldLogToConsole) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
}

#pragma mark - NSNotification

static void * AFNetworkRequestStartDate = &AFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);

    if (!request) {
        return;
    }

    objc_setAssociatedObject(notification.object, AFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    }

    switch (self.level) {
        case MMLoggerLevelVerbose:
        case MMLoggerLevelDebug:
            [self debug:@"%@ '%@': %@ %@", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], body];
            break;
        case MMLoggerLevelInfo:
            [self info:@"%@ '%@'", [request HTTPMethod], [[request URL] absoluteString]];
            break;
        default:
            break;
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);
    NSURLResponse *response = [notification.object response];
    NSError *error = [notification.object error];

    if (!request && !response) {
        return;
    }

    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger) [(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }

    NSString *responseString = nil;
    if ([[notification object] respondsToSelector:@selector(responseString)]) {
        responseString = [[notification object] responseString];
    }

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, AFNetworkRequestStartDate)];

    if (error) {
        switch (self.level) {
            case MMLoggerLevelVerbose:
            case MMLoggerLevelDebug:
            case MMLoggerLevelInfo:
            case MMLoggerLevelWarn:
            case MMLoggerLevelError:
                [self error:@"%@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error];
            default:
                break;
        }
    } else {
        switch (self.level) {
            case MMLoggerLevelVerbose:
            case MMLoggerLevelDebug:
                [self debug:@"%ld '%@' [%.04f s]: %@ %@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields, responseString];
                break;
            case MMLoggerLevelInfo:
                [self info:@"%ld '%@' [%.04f s]", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime];
                break;
            default:
                break;
        }
    }
}

@end
