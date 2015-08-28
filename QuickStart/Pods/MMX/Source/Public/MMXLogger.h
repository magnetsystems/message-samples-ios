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

typedef NS_ENUM(NSUInteger, MMXLoggerLevel) {
    MMXLoggerLevelOff,
    MMXLoggerLevelVerbose,
    MMXLoggerLevelDebug,
    MMXLoggerLevelInfo,
    MMXLoggerLevelWarn,
    MMXLoggerLevelError
};

typedef NS_OPTIONS(NSInteger, MMXLoggerOptions){
    MMXTTYLogging  = 1 << 0,
    MMXFileLogging = 1 << 1,
};

/**
 `MMXLogger` logs requests and responses made by AFNetworking, with an adjustable level of detail.

 Applications must enable the shared instance of `MMXLogger` in `AppDelegate -application:didFinishLaunchingWithOptions:`:

        [[MMXLogger sharedLogger] startLogging];
 */
@interface MMXLogger : NSObject

/**
 The level of logging detail. See "Logging Levels" for possible values. `MMXLoggerLevelInfo` by default.
 */
@property (nonatomic, assign) MMXLoggerLevel level;

/**
 The type of logging. See "Logging Options" for possible values. `MMXTTYLogging` by default.
 */
@property (nonatomic, assign) MMXLoggerOptions options;

/**
 Retrieves the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses.
 */
- (void)startLogging;

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

@end


/**
Logging configuration key - rollingFrequency  */
extern NSString * const MMXLoggingConfigKeyRollingFrequency;
extern int const MMXLoggingConfigDefaultRollingFrequency;

/**
Logging configuration key - MaximumFileSize  */
extern NSString * const MMXLoggingConfigKeyMaximumFileSize;
extern int const MMXLoggingConfigDefaultMaximumFileSize;

/**
Logging configuration key - MaximumNumberOfLogFiles  */
extern NSString * const MMXLoggingConfigKeyMaximumNumberOfLogFiles;
extern int const MMXLoggingConfigDefaultMaximumNumberOfLogFiles;
