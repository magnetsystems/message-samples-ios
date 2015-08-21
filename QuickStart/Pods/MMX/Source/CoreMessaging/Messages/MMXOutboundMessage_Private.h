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


#import "MMXOutboundMessage.h"
@class MMXInternalMessageAdaptor;
@class NSXMLElement;

@interface MMXOutboundMessage ()

@property (nonatomic, readwrite) NSArray *recipients;

/**
 *  Unique UUID for the message to allow tracking.
 */
@property (nonatomic, copy, readwrite) NSString *messageID;

/**
 *  NSDictionary used to pass additional information that would be useful for displaying or consuming the message.
 */
@property (nonatomic, copy, readwrite) NSDictionary *metaData;

/**
 *  The content of the message in NSString form.
 */
@property (nonatomic, copy, readwrite) NSString *messageContent;

- (NSXMLElement *)contentAsXMLForType:(NSString *)type;
- (NSXMLElement *)metaDataAsXML;
+ (instancetype)initWithMessage:(MMXInternalMessageAdaptor *)message;

@end