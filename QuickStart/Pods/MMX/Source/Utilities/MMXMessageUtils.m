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


#import "MMXMessageUtils.h"
#import "MMXConstants.h"
#import "MMXUtils.h"
#import "DDXML.h"

@implementation MMXMessageUtils

#pragma mark - Extract Data From Message

+ (NSUInteger)sizeOfMessageContent:(NSString *)content metaData:(NSDictionary *)metaData {
	NSUInteger contentBytes = [content ?: @"" lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSData * data = [NSKeyedArchiver archivedDataWithRootObject:metaData ?: @{}];
	NSUInteger metaDataBytes = [data length];
	NSUInteger totalBytes = contentBytes + metaDataBytes;
	return totalBytes;
}

+ (NSString *)extractPayload:(NSArray *)payLoadElements {
	if ([payLoadElements count] > 0) {
		NSXMLElement *payloadXMLElement = payLoadElements[0];
		return [payloadXMLElement stringValue];
	}
	//NSLog(@"Badly formatted message ?");
	return @"";
}

+ (NSDictionary *)extractMetaData:(NSArray *)metaElements {
	if ([metaElements count] > 0) {
		NSXMLElement* metaElement = metaElements[0];
		NSString* metaJSON = [metaElement stringValue];
		if (metaJSON && [metaJSON length] > 0) {
			NSData* jsonData = [metaJSON dataUsingEncoding:NSUTF8StringEncoding];
			NSError* readError;
			NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&readError];
			if (!readError) {
				return dict;
			}
		}
	}
	return @{};
}

+ (BOOL)isValidMetaData:(NSDictionary *)metaData {
	if (metaData == nil) {
		return YES;
	}
	for (id value in [metaData allValues]) {
		if (![value isKindOfClass:[NSString class]]) {
			return NO;
		}
	}
	return YES;
}

#pragma mark - Payload Conversion

+ (NSXMLElement *)xmlFromContentString:(NSString *)contentString andMessageType:(NSString *)type {
	NSXMLElement *payloadElement = [[NSXMLElement alloc] initWithName:MXpayloadElement];
	
	NSXMLNode* mtypeAttribute = [self buildAttributeNodeWith:@"mtype" attributeValue:type];
	
	
	NSString* offsetValue = offsetValue = [NSString stringWithFormat:@"%d/%d/%d", 0, (int)contentString.length, (int)contentString.length];
	NSXMLNode* chunkAttribute = [self buildAttributeNodeWith:@"chunk" attributeValue:offsetValue];
	NSXMLNode* stampAttribute = [self buildAttributeNodeWith:@"stamp"
													attributeValue:[MMXUtils iso8601FormatTimeStamp]];
	
	[payloadElement addAttribute:mtypeAttribute];
	[payloadElement addAttribute:chunkAttribute];
	[payloadElement addAttribute:stampAttribute];
	
	[payloadElement setStringValue:contentString];
	
	return payloadElement;
}

+ (NSXMLElement *)xmlFromMetaDataDict:(NSDictionary *)metaData {
	if (metaData == nil) {
		return nil;
	}
	NSXMLElement *metaDataElement = [[NSXMLElement alloc] initWithName:MXmetaElement];
	
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaData
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	NSString *json = [[NSString alloc] initWithData:jsonData
										   encoding:NSUTF8StringEncoding];
	
	[metaDataElement setStringValue:json];
	
	if (error == nil) {
		return metaDataElement;
	}
	return nil;
}

+(NSXMLNode*)buildAttributeNodeWith:(NSString *)name
					 attributeValue:(NSString *)attributeValue {
	NSXMLNode* attribute = [NSXMLNode attributeWithName:name stringValue:attributeValue];
	return attribute;
}

@end
