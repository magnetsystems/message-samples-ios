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

#import "XMPPIQ.h"
#import "MMXInternalMessageAdaptor_Private.h"
#import "MMXConstants.h"
#import "MMXTopic_Private.h"
#import "MMXUserID_Private.h"
#import "MMXPubSubMessage_Private.h"
#import "MMXUtils.h"
#import "MMXUserID_Private.h"
#import "MMXEndpoint_Private.h"
#import "MMXInternalAddress.h"

#import "NSXMLElement+XMPP.h"
#import "XMPPJID+MMX.h"

#import "XMPPIQ.h"
#import "XMPPMessage.h"
#import "NSString+XEP_0106.h"

#import "DDXML.h"
#import <CoreLocation/CoreLocation.h>

@implementation MMXInternalMessageAdaptor

static  NSString *const MESSAGE_ATTRIBUE_CONTENT_TYPE = @"ctype";
static  NSString *const MESSAGE_ATTRIBUE_MESSAGE_TYPE = @"mtype";
static  NSString *const MESSAGE_ATTRIBUE_CHUNK = @"chunk";
static  NSString *const MESSAGE_ATTRIBUE_STAMP = @"stamp";

//FIXME: Refactor everything in theis class!!!
- (instancetype)initWithXMPPMessage:(XMPPMessage*)xmppMessage {
    if ((self = [super init])) {
        XMPPJID* recipient = [xmppMessage to] ;
        XMPPJID* sender =[xmppMessage from];
		NSString * senderUsername = [sender usernameWithoutAppID];
		NSString * recipientUsername = [recipient usernameWithoutAppID];
		if ([MMXUtils objectIsValidString:senderUsername]) {
			_senderUserID = [MMXUserID userIDWithUsername:[senderUsername jidUnescapedString]];
			if ([MMXUtils objectIsValidString:[sender resource]]) {
				_senderEndpoint = [MMXEndpoint endpointWithUsername:[senderUsername jidUnescapedString] deviceID:[sender resource]];
			}
		}
		if ([MMXUtils objectIsValidString:recipientUsername]) {
			_targetUserID = [MMXUserID userIDWithUsername:[recipientUsername jidUnescapedString]];
		}
        _messageID = [xmppMessage elementID];
        NSXMLElement *mmxElement = [xmppMessage elementForName:MXmmxElement];

        //payload
        NSArray* payLoadElements = [mmxElement elementsForName:MXpayloadElement];
        _messageContent = [MMXInternalMessageAdaptor extractPayload:payLoadElements];
		if (payLoadElements && payLoadElements.count) {
			NSString * stamp = [[payLoadElements[0] attributeForName:@"stamp"] stringValue];
			if (stamp && ![stamp isEqualToString:@""]) {
				_timestamp = [MMXUtils dateFromiso8601Format:stamp];
			}
			NSXMLNode* mtype = [payLoadElements[0] attributeForName:MESSAGE_ATTRIBUE_MESSAGE_TYPE];
			_mType = mtype ? [mtype stringValue] : nil;
		}

        //meta
        NSArray* metaElements = [mmxElement elementsForName:MXmetaElement];
        _metaData = [MMXInternalMessageAdaptor extractMetaData:metaElements];
		
		NSArray* mmxMetaElements = [mmxElement elementsForName:MXmmxMetaElement];
		if (mmxMetaElements) {
			NSDictionary *mmxMetaDict = [MMXInternalMessageAdaptor extractMMXMetaData:mmxMetaElements];
			_recipients = [MMXInternalMessageAdaptor extractRecipientsFromMMXMetaDict:mmxMetaDict];
			
			MMXUserID *senderID = [MMXInternalMessageAdaptor extractSenderFromMMXMetaDict:mmxMetaDict];
			if (senderID) {
				_senderUserID = senderID;
				_senderEndpoint.userID = senderID;
			}
		}

        NSArray* elements = [xmppMessage elementsForXmlns:MXnsDeliveryReceipt];
        BOOL deliveryFlag = NO;
        if ([elements count]) {
            deliveryFlag = YES;
        }
        _deliveryReceiptRequested = deliveryFlag;
    }
    return self;
}

- (instancetype)initWithPubSubMessage:(XMPPMessage *)xmppMessage {
	if ((self = [super init])) {
		XMPPJID* recipient = [xmppMessage to] ;
		XMPPJID* sender =[xmppMessage from];
		NSString * username = [sender usernameWithoutAppID];
		_senderUserID = [MMXUserID userIDWithUsername:[username jidUnescapedString]];
		_senderEndpoint = [MMXEndpoint endpointWithUsername:[username jidUnescapedString] deviceID:[sender resource]];
		NSString *targetUsername = [[recipient usernameWithoutAppID] jidUnescapedString];
		_targetUserID = [MMXUserID userIDWithUsername:targetUsername];
		NSXMLElement *eventElement = [xmppMessage elementForName:@"event"];
		NSXMLElement *itemsElement = [eventElement elementForName:@"items"];
		NSXMLNode* node = [itemsElement attributeForName:@"node"];
		
		//Topic
		_topic = [MMXTopic topicFromNode:[node stringValue]];
		NSXMLElement *itemElement = [itemsElement elementForName:@"item"];
		_messageID = [[itemElement attributeForName:@"id"] stringValue];
		NSXMLElement *mmxElement = [itemElement elementForName:MXmmxElement xmlns:MXnsDataPayload];
		
		//payload
		NSArray* payLoadElements = [mmxElement elementsForName:MXpayloadElement];
		if (payLoadElements.count) {
			NSXMLElement *payLoadElement = payLoadElements[0];
			NSXMLNode* mtype = [payLoadElement attributeForName:MESSAGE_ATTRIBUE_MESSAGE_TYPE];
			_mType = mtype ? [mtype stringValue] : nil;
		}
		_messageContent = [MMXInternalMessageAdaptor extractPayload:payLoadElements];
		NSXMLNode* mtype = [[mmxElement elementForName:MXpayloadElement] attributeForName:MESSAGE_ATTRIBUE_MESSAGE_TYPE];
		NSXMLNode* timestamp = [[mmxElement elementForName:MXpayloadElement] attributeForName:@"stamp"];
		_mType = mtype ? [mtype stringValue] : nil;
		if ([timestamp stringValue] && ![[timestamp stringValue] isEqualToString:@""]) {
			_timestamp = [MMXUtils dateFromiso8601Format:[timestamp stringValue]];
		}
		
		//meta
		NSArray* metaElements = [mmxElement elementsForName:MXmetaElement];
		_metaData = [MMXInternalMessageAdaptor extractMetaData:metaElements];
		
		NSArray* mmxMetaElements = [mmxElement elementsForName:MXmmxMetaElement];
		if (mmxMetaElements) {
			NSDictionary *mmxMetaDict = [MMXInternalMessageAdaptor extractMMXMetaData:mmxMetaElements];
			
			MMXUserID *senderID = [MMXInternalMessageAdaptor extractSenderFromMMXMetaDict:mmxMetaDict];
			if (senderID) {
				_senderUserID = senderID;
				_senderEndpoint.userID = senderID;
			}
		}
		
		_deliveryReceiptRequested = NO;
	}
	return self;
}

- (instancetype)initWith:(NSArray *)recipients
             withContent:(NSString *)content
             messageType:(NSString *)mType
                metaData:(NSDictionary *)metaData {
	
    if (self = [super init]) {
		_recipients = recipients.copy;
		_messageContent = content.copy;
        _contentType = MXctypeJSON;
        if (nil == mType) {
            mType = @"default";
        }
        _mType = mType.copy;
        _metaData = metaData.copy;
    }
    return self;
}

+ (instancetype)messageTo:(NSArray *)recipients
              withContent:(NSString *)content
              messageType:(NSString *)messageType
                 metaData:(NSDictionary *)metaData {
    return [[MMXInternalMessageAdaptor alloc] initWith:recipients withContent:content messageType:messageType metaData:metaData];
}

+ (NSArray *)pubsubMessagesFromFetchResponseIQ:(XMPPIQ *)iq topic:(MMXTopic *)topic error:(NSError **)error {
    //FIXME: handle error properly
    NSMutableArray *messageArray = @[].mutableCopy;
    NSXMLElement *mmxElement = [iq elementForName:@"mmx"];
    
    NSError *jsonError;
    NSString* jsonContent =  [[mmxElement childAtIndex:0] stringValue];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    if (jsonError) {
		*error = jsonError;
        return nil;
    }
    for (NSDictionary * dict in jsonDictionary[@"items"]) {
        NSError * xmlError;
        NSString * payloadString = dict[@"payloadXML"];
        NSXMLElement *messageElement = [[NSXMLElement alloc] initWithXMLString:payloadString error:&xmlError];
        //payload
        NSArray* payLoadElements = [messageElement elementsForName:MXpayloadElement];
        NSString * content = [MMXInternalMessageAdaptor extractPayload:payLoadElements];
        
        NSXMLNode* mtype = [payLoadElements[0] attributeForName:MESSAGE_ATTRIBUE_MESSAGE_TYPE];
        NSString * mTypeExtracted = mtype ? [mtype stringValue] : nil;
        
        //meta
        NSArray* metaElements = [messageElement elementsForName:MXmetaElement];
        NSDictionary * metaData = [MMXInternalMessageAdaptor extractMetaData:metaElements];
        NSString * stamp = [[payLoadElements[0] attributeForName:@"stamp"] stringValue];
		NSDate * timestamp = [MMXUtils dateFromiso8601Format:stamp];
        NSString * messageID = dict[@"itemId"];
        if (!xmlError) {
            MMXInternalMessageAdaptor * message =  [[MMXInternalMessageAdaptor alloc] initWith:nil withContent:content messageType:mTypeExtracted metaData:metaData ? metaData : @{}];
            message.timestamp = timestamp;
            message.messageID = messageID;
            message.topic = topic;
            [messageArray addObject:[MMXPubSubMessage initWithMessage:message]];
        }
    }
    return messageArray.copy;
}

#pragma mark - Extract Data From Message

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

+ (NSDictionary *)extractMMXMetaData:(NSArray *)metaElements {
	if ([metaElements count] > 0) {
		NSXMLElement *metaElement = metaElements[0];
		NSString* metaJSON = [metaElement stringValue];
		if (metaJSON && [metaJSON length] > 0) {
			NSData* jsonData = [metaJSON dataUsingEncoding:NSUTF8StringEncoding];
			NSError* readError;
			NSDictionary * mmxMetaDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&readError];
			if (!readError) {
				return mmxMetaDict;
			}
		}
	}
	return @{};
}

+ (MMXUserID *)extractSenderFromMMXMetaDict:(NSDictionary *)mmxMetaDict {
	if (mmxMetaDict && mmxMetaDict[@"To"]) {
		NSDictionary *senderDict = mmxMetaDict[@"From"];
		if (senderDict) {
			MMXInternalAddress *address = [MMXInternalAddress new];
			address.username = senderDict[kAddressUsernameKey];
			address.displayName = senderDict[kAddressDisplayNameKey];
			MMXUserID *senderID = [MMXUserID userIDFromAddress:address];
			return senderID;
		}
	}
	return nil;
}

+ (NSArray *)extractRecipientsFromMMXMetaDict:(NSDictionary *)mmxMetaDict {
	if (mmxMetaDict && mmxMetaDict[@"To"]) {
		NSArray *tempRecipientArray = mmxMetaDict[@"To"];
		NSMutableArray *recipientOutputArray = [NSMutableArray arrayWithCapacity:tempRecipientArray.count];
		for (NSDictionary *userDict in tempRecipientArray) {
			if (userDict[kAddressUsernameKey] && userDict[kAddressUsernameKey] != [NSNull null] && ![userDict[kAddressUsernameKey] isEqualToString:@""]) {
				if (userDict[kAddressDeviceIDKey] && userDict[kAddressDeviceIDKey] != [NSNull null] && ![userDict[kAddressDeviceIDKey] isEqualToString:@""]) {
					MMXEndpoint *end = [MMXEndpoint endpointWithUsername:userDict[kAddressUsernameKey] deviceID:userDict[kAddressDeviceIDKey]];
					if (userDict[kAddressDisplayNameKey] && userDict[kAddressDisplayNameKey] != [NSNull null] && ![userDict[kAddressDisplayNameKey] isEqualToString:@""]) {
						end.userID.displayName = userDict[kAddressDisplayNameKey];
					}
					[recipientOutputArray addObject:end];
				} else {
					MMXUserID *user = [MMXUserID userIDWithUsername:userDict[kAddressUsernameKey]];
					if (userDict[kAddressDisplayNameKey] && userDict[kAddressDisplayNameKey] != [NSNull null] && ![userDict[kAddressDisplayNameKey] isEqualToString:@""]) {
						user.displayName = userDict[kAddressDisplayNameKey];
					}
					[recipientOutputArray addObject:user];
				}
			}
			
		}
		return recipientOutputArray.copy;
	}
	//NSLog(@"Badly formatted message ?");
	return @[];
}

#pragma mark - Helper Methods

- (BOOL)deliveryReceiptRequested {
    return _deliveryReceiptRequested;
}

#pragma mark - Payload Conversion

- (NSXMLElement *)contentToXML {
    NSXMLElement *payloadElement = [[NSXMLElement alloc] initWithName:MXpayloadElement];
    
    NSXMLNode* mtypeAttribute = [MMXInternalMessageAdaptor buildAttributeNodeWith:MESSAGE_ATTRIBUE_MESSAGE_TYPE attributeValue:self.mType];
    
    
    NSString* offsetValue = offsetValue = [NSString stringWithFormat:@"%d/%d/%d", 0, (int)self.messageContent.length, (int)self.messageContent.length];
    NSXMLNode* chunkAttribute = [MMXInternalMessageAdaptor buildAttributeNodeWith:MESSAGE_ATTRIBUE_CHUNK attributeValue:offsetValue];
    NSXMLNode* stampAttribute = [MMXInternalMessageAdaptor buildAttributeNodeWith:MESSAGE_ATTRIBUE_STAMP
                                                    attributeValue:[MMXUtils iso8601FormatTimeStamp]];
    
    [payloadElement addAttribute:mtypeAttribute];
    [payloadElement addAttribute:chunkAttribute];
    [payloadElement addAttribute:stampAttribute];
    
    [payloadElement setStringValue:self.messageContent];
    
    return payloadElement;
}

- (NSXMLElement *)metaDataToXML {
    if (self.metaData) {
        NSXMLElement *metaDataElement = [[NSXMLElement alloc] initWithName:MXmetaElement];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.metaData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData
                                               encoding:NSUTF8StringEncoding];
        
        [metaDataElement setStringValue:json];
        
        return metaDataElement;
    }
    return nil;
}

- (NSXMLElement *)recipientsAndSenderAsXML {
	if (self.recipients == nil || self.recipients.count < 1) {
		return nil;
	}
	NSXMLElement *metaDataElement = [[NSXMLElement alloc] initWithName:@"mmxmeta"];
	
	NSMutableArray *recipientArray = @[].mutableCopy;
	for (id<MMXAddressable> recipient in self.recipients) {
		MMXInternalAddress *address = recipient.address;
		if (address) {
			[recipientArray addObject:[address asDictionary]];
		}
	}
	
	MMXInternalAddress *address = self.senderUserID.address;

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"To":recipientArray,
																 @"From":address ? [address asDictionary] : [NSNull null]}
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _messageID = [coder decodeObjectForKey:@"_messageID"];
        _metaData = [coder decodeObjectForKey:@"_metaData"];
        _topic = [coder decodeObjectForKey:@"_topic"];
        _messageContent = [coder decodeObjectForKey:@"_messageContent"];
		_senderUserID = [coder decodeObjectForKey:@"_senderUserID"];
		_senderEndpoint = [coder decodeObjectForKey:@"_senderEndpoint"];
        _senderUserID = [coder decodeObjectForKey:@"_senderUserID"];
        _recipients = [coder decodeObjectForKey:@"_recipients"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.messageID forKey:@"_messageID"];
    [coder encodeObject:self.metaData forKey:@"_metaData"];
    [coder encodeObject:self.topic forKey:@"_topic"];
    [coder encodeObject:self.messageContent forKey:@"_messageContent"];
	[coder encodeObject:self.senderUserID forKey:@"_senderUserID"];
	[coder encodeObject:self.senderEndpoint forKey:@"_senderEndpoint"];
    [coder encodeObject:self.senderUserID forKey:@"_senderUserID"];
    [coder encodeObject:self.recipients forKey:@"_recipients"];
}


@end
