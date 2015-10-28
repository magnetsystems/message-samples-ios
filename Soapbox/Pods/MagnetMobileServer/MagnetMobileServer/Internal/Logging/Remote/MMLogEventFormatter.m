/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMLogEventFormatter.h"
#import "MMLogEvent.h"
#import "MMValueTransformer.h"


@implementation MMLogEventFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    MMLogEvent *logEvent;
    if([self isLogEvent:logMessage]) {
        logEvent = (MMLogEvent *) logMessage.tag;
        if(!logEvent.type) {
            logEvent.type = @"BUSINESS";
        }
        if(!logEvent.tags) {
            logEvent.tags = @[@"BUSINESS"];
        }
        if(!logEvent.utctime) {
            logEvent.utctime = [[NSDate date]timeIntervalSince1970];
        }
        if(!logEvent.identifier) {
            logEvent.identifier = [[NSUUID UUID] UUIDString];
        }
    } else {
        logEvent = [self logMessageToEvent:logMessage];
    }

    NSDictionary *logDictionary = [[MMValueTransformer resourceNodeTransformerForClass:[MMLogEvent class]] reverseTransformedValue:logEvent];
    NSData *logData = [NSJSONSerialization dataWithJSONObject:logDictionary options:0 error:nil];
    NSString *logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    return  logStr;
}

- (bool) isLogEvent:(DDLogMessage *) logMessage {
    return logMessage.level == DDLogLevelAll && logMessage.tag && [logMessage.tag isKindOfClass:[MMLogEvent class]];
}

- (MMLogEvent *) logMessageToEvent:(DDLogMessage *) logMessage {
    MMLogEvent *logEvent = [[MMLogEvent alloc] init];
    logEvent.utctime = [[NSDate date]timeIntervalSince1970];
    logEvent.identifier = [[NSUUID UUID] UUIDString];

    logEvent.category = @"iOS";
    logEvent.name = @"log";
    logEvent.type = @"SYSTEM";
    logEvent.subcategory = [self logLevelToString:logMessage.level];
    logEvent.payload = @{@"__message" : logMessage.message};
    logEvent.tags = @[@"SYSTEM", [self logLevelToString:logMessage.level]];

    return logEvent;
}

- (NSString *) logLevelToString:(DDLogLevel) logLevel {
    NSString *result = nil;

    switch(logLevel) {
        case DDLogLevelVerbose:
            result = @"Verbose";
            break;
        case DDLogLevelDebug:
            result = @"Debug";
            break;
        case DDLogLevelInfo:
            result = @"Info";
            break;
        case DDLogLevelWarning:
            result = @"Warning";
            break;
        case DDLogLevelError:
            result = @"Error";
            break;
        default:
            result = @"unknown";
    }

    return result;
}

@end