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
 
#import <Foundation/Foundation.h>

@class MMServiceAdapter;
@class MMLogEvent;

typedef NS_ENUM(NSUInteger, MMLoggerLevel) {
    MMLoggerLevelOff,
    MMLoggerLevelVerbose,
    MMLoggerLevelDebug,
    MMLoggerLevelInfo,
    MMLoggerLevelWarn,
    MMLoggerLevelError
};

typedef NS_OPTIONS(NSInteger, MMLoggerOptions){
    MMTTYLogging  = 1 << 0,
    MMFileLogging = 1 << 1,
    MMRemoteLogging = 1 << 2,
};

/**
 `MMLogger` logs requests and responses made by AFNetworking, with an adjustable level of detail.

 Applications must enable the shared instance of `MMLogger` in `AppDelegate -application:didFinishLaunchingWithOptions:`:

        [[MMLogger sharedLogger] startLogging];
 */
@interface MMLogger : NSObject

/**
 The level of logging detail. See "Logging Levels" for possible values. `MMLoggerLevelInfo` by default.
 */
@property (nonatomic, assign) MMLoggerLevel level;

/**
 The type of logging. See "Logging Options" for possible values. `MMTTYLogging` by default.
 */
@property (nonatomic, assign) MMLoggerOptions options;


@property (nonatomic, strong) MMServiceAdapter *serviceAdapter;

/**
 Retrieves the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses.
 */
- (void)startLogging;

/**
Flush logging (applicable to MMRemoteLogging).
*/
- (void)flushLogging;

/**
 Stop logging requests and responses.
 */
- (void)stopLogging;

/**
 Log a message with error level.
 */
- (void)error:(NSString *)message, ... __attribute__ ((format (__NSString__, 1, 2)));

/**
 Log a message with warning level.
 */
- (void)warn:(NSString *)message, ... __attribute__ ((format (__NSString__, 1, 2)));

/**
 Log a message with info level.
 */
- (void)info:(NSString *)message, ... __attribute__ ((format (__NSString__, 1, 2)));

/**
 Log a message with debug level.
 */
- (void)debug:(NSString *)message, ... __attribute__ ((format (__NSString__, 1, 2)));

/**
 Log a message with verbose level.
 */
- (void)verbose:(NSString *)message, ... __attribute__ ((format (__NSString__, 1, 2)));

//---------logging methods for swift---------
/**
Log a message with error level.
*/
- (void)error:(NSString *)message args:(va_list)args;

/**
Log a message with warning level.
*/
- (void)warn:(NSString *)message args:(va_list)args;

/**
Log a message with info level.
*/
- (void)info:(NSString *)message args:(va_list)args;

/**
Log a message with debug level.
*/
- (void)debug:(NSString *)message args:(va_list)args;

/**
Log a message with verbose level.
*/
- (void)verbose:(NSString *)message args:(va_list)args;

/**
Log a event
*/
- (void)logEvent:(MMLogEvent *) event;

@end


/**
Logging configuration key - rollingFrequency  */
extern NSString * const MMLoggingConfigKeyRollingFrequency;
extern int const MMLoggingConfigDefaultRollingFrequency;

/**
Logging configuration key - MaximumFileSize  */
extern NSString * const MMLoggingConfigKeyMaximumFileSize;
extern int const MMLoggingConfigDefaultMaximumFileSize;

/**
Logging configuration key - MaximumNumberOfLogFiles  */
extern NSString * const MMLoggingConfigKeyMaximumNumberOfLogFiles;
extern int const MMLoggingConfigDefaultMaximumNumberOfLogFiles;
