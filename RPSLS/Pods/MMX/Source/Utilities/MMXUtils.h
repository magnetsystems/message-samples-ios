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

@class NSXMLElement;
@class DDXMLElement;
@class DDXMLNode;

@interface MMXUtils : NSObject

+ (NSXMLElement *)mmxElementFromValidJSONObject:(id)object
										  xmlns:(NSString *)xmlns
							 commandStringValue:(NSString *)command
										  error:(NSError**)error;

+ (NSXMLElement *)pubsubElementFromValidJSONObject:(id)object
                                             xmlns:(NSString *)xmlns
                                commandStringValue:(NSString *)command
                                             error:(NSError**)error;

+ (NSXMLElement *)contentToXML:(NSString *)content
						  type:(NSString *)type;

+ (NSXMLElement *)metaDataToXML:(NSDictionary *)metaData;

+ (DDXMLNode *)buildAttributeNodeWith:(NSString *)name
					   attributeValue:(NSString *)attributeValue;

+ (NSDateFormatter *)dateFormatter8601;

+ (NSString *)iso8601FormatTimeStamp;

+ (NSString *)stringIniso8601Format:(NSDate *)date;

+ (NSDate *)dateFromiso8601Format:(NSString *)timestamp;

+ (NSString *)deviceName;

+ (BOOL)objectIsValidString:(id)obj;

+ (BOOL)validateAgainstDefaultCharacterSet:(NSString *)string
							   allowSpaces:(BOOL)allowSpaces;

+ (BOOL)validateTag:(NSString *)tag;

+ (NSString *)generateUUID;

+ (NSError *)mmxErrorWithTitle:(NSString *)title
					   message:(NSString *)message
						  code:(int)code;

@end

static inline id mmxNullSafeConversion(id source) {
    if (source == nil || [source isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return source;
    }
}