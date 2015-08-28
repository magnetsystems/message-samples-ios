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

#import "DDXMLElement.h"
#import "MMXUtils.h"
#import "MMXConstants.h"
#import "NSXMLElement+XMPP.h"
#import "DDXML.h"

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#else
	#import <SystemConfiguration/SystemConfiguration.h>
#endif


@implementation MMXUtils

//FIXME: Refactor MMX and PubSub to use one method under the hood
+ (NSXMLElement *)mmxElementFromValidJSONObject:(id)object xmlns:(NSString *)xmlns commandStringValue:(NSString *)command error:(NSError**)error {
    if (![NSJSONSerialization isValidJSONObject:object]) {
 		if (error != NULL) {
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: NSLocalizedString(@"Not a valid object", nil),
									   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The object you passed in is not a valid JSON object.", nil),
									   };

			*error = [NSError errorWithDomain:MMXErrorDomain
										 code:500
									 userInfo:userInfo];
		}
        return nil;
    }
	
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    if (json) {
        NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:xmlns];
        [mmxElement addAttributeWithName:MXcommandString stringValue:command];
        [mmxElement setStringValue:json];
        [mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
        return mmxElement;
    }
    return nil;
}

+ (NSXMLElement *)pubsubElementFromValidJSONObject:(id)object xmlns:(NSString *)xmlns commandStringValue:(NSString *)command error:(NSError**)error {
    if (![NSJSONSerialization isValidJSONObject:object]) {
		if (error != NULL) {
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: NSLocalizedString(@"Not a valid object", nil),
									   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The object you passed in is not a valid JSON object.", nil),
									   };
			*error = [NSError errorWithDomain:MMXErrorDomain
										 code:500
									 userInfo:userInfo];
		}
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    if (json) {
        NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:@"pubsub" xmlns:xmlns];
        [mmxElement addAttributeWithName:MXcommandString stringValue:command];
        [mmxElement setStringValue:json];
        [mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
        return mmxElement;
    }
    return nil;
}

+ (NSXMLElement *)contentToXML:(NSString *)content type:(NSString *)type{
    NSXMLElement *payloadElement = [[NSXMLElement alloc] initWithName:MXpayloadElement];

    NSXMLNode* mtypeAttribute = [MMXUtils buildAttributeNodeWith:@"mtype" attributeValue:type];


    NSString* offsetValue = [NSString stringWithFormat:@"%d/%d/%d", 0, (int)content.length, (int)content.length];
    NSXMLNode* chunkAttribute = [MMXUtils buildAttributeNodeWith:@"chunk" attributeValue:offsetValue];
    NSXMLNode* stampAttribute = [MMXUtils buildAttributeNodeWith:@"stamp"
                                                          attributeValue:[self iso8601FormatTimeStamp]];

    [payloadElement addAttribute:mtypeAttribute];
    [payloadElement addAttribute:chunkAttribute];
    [payloadElement addAttribute:stampAttribute];

    [payloadElement setStringValue:content];

    return payloadElement;
}

+ (NSXMLElement *)metaDataToXML:(NSDictionary *)metaData {
    if (metaData) {
        NSXMLElement *metaDataElement = [[NSXMLElement alloc] initWithName:MXmetaElement];

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];

        [metaDataElement setStringValue:json];

        return metaDataElement;
    }
    return nil;
}

+ (NSXMLNode*)buildAttributeNodeWith:(NSString *)name
                     attributeValue:(NSString *)attributeValue {
    NSXMLNode* attribute = [NSXMLNode attributeWithName:name stringValue:attributeValue];
    return attribute;
}

+ (NSString *)deviceName {
#if TARGET_OS_IPHONE
	return [UIDevice currentDevice].name;
#else
	return (__bridge id)SCDynamicStoreCopyComputerName(NULL, NULL);
#endif
}

+ (BOOL)objectIsValidString:(id)obj {
	if (obj == nil) {
		return NO;
	}
	if (![obj isKindOfClass:[NSString class]]) {
		return NO;
	}
	if ([obj isEqualToString:@""]) {
		return NO;
	}
	return YES;
}

+ (BOOL)validateAgainstDefaultCharacterSet:(NSString *)string allowSpaces:(BOOL)allowSpaces {
	NSString * validCharacters = [NSString stringWithFormat:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-.%@",allowSpaces ? @" " : @""];
	NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validCharacters];
	NSCharacterSet *invalidSet = [allowedSet invertedSet];
	NSRange r = [string rangeOfCharacterFromSet:invalidSet];
	if (r.location != NSNotFound) {
		return NO;
	}
	return YES;
}

+ (BOOL)validateTag:(NSString *)tag {
	if (tag == nil) {
		return NO;
	}
	return ([self validateAgainstDefaultCharacterSet:tag allowSpaces:NO] && tag.length > 0 && tag.length < 26);
}

+ (NSString *)generateUUID {
	return [[NSUUID UUID] UUIDString];
}

+ (NSError *)mmxErrorWithTitle:(NSString *)title message:(NSString *)message code:(int)code {
	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey: NSLocalizedString(title, nil),
							   NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, nil),
							   };
	NSError *error = [NSError errorWithDomain:MMXErrorDomain
										 code:code
									 userInfo:userInfo];
	
	return error;
}


#pragma mark - Date Helper Methods

+ (NSDateFormatter *)dateFormatter8601 {
	static NSDateFormatter *__dateFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__dateFormatter = [[NSDateFormatter alloc] init];
		[__dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		__dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
	});
	return __dateFormatter;
}

+ (NSString*)iso8601FormatTimeStamp {
	NSDate* currentTimeStamp = [NSDate date];
	return [[MMXUtils dateFormatter8601] stringFromDate:currentTimeStamp];
}

+ (NSString *)stringIniso8601Format:(NSDate *)date {
	return [[MMXUtils dateFormatter8601] stringFromDate:date];
}

+ (NSDate *)dateFromiso8601Format:(NSString *)timestamp {
	return [[MMXUtils dateFormatter8601] dateFromString:timestamp];
}

@end
