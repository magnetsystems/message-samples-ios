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

#import "MMXConstants.h"

@implementation MMXConstants
NSString * const MXnsAppReg = @"com.magnet:appreg";
NSString * const MXnsDevice = @"com.magnet:dev";
NSString * const MXnsMsgAck = @"com.magnet:msg:ack";
NSString * const MXnsDataPayload = @"com.magnet:msg:payload";
NSString * const MXnsServerSignal = @"com.magnet:msg:signal";
NSString * const MXnsMsgState = @"com.magnet:msg:state";
NSString * const MXnsDeliveryReceipt = @"urn:xmpp:receipts";
NSString * const MXnsUser = @"com.magnet:user";
NSString * const MXnsPubSub = @"com.magnet:pubsub";
NSString * const MXmmxElement = @"mmx";
NSString * const MXpayloadElement = @"payload";
NSString * const MXrequestElement = @"request";
NSString * const MXreceivedElement = @"received";
NSString * const MXmetaElement = @"meta";
NSString * const MXmmxMetaElement = @"mmxmeta";
NSString * const MXosType = @"IOS";
NSString * const MXcommandString = @"command";
NSString * const MXcommandRegister = @"REGISTER";
NSString * const MXcommandUnregister = @"UNREGISTER";
NSString * const MXcommandListTopics = @"listtopics";
NSString * const MXcommandGetLatest = @"getlatest";
NSString * const MXcommandAck = @"ack";
NSString * const MXcommandCreate = @"create";
NSString * const MXcommandCreateTopic = @"createtopic";
NSString * const MXcommandDeleteTopic = @"deletetopic";
NSString * const MXcommandSubscribe = @"subscribe";
NSString * const MXcommandUnsubscribe = @"unsubscribe";
NSString * const MXcommandUnsubscribeForDevice = @"unsubscribeForDev";
NSString * const MXcommandGetSubscribers = @"getSubscribers";
NSString * const MXcommandRetract = @"retract";
NSString * const MXcommandRetractAll = @"retractAll";
NSString * const MXcommandGetSummary = @"getSummary";
NSString * const MXcommandQuery = @"query";
NSString * const MXcommandQueryTopic = @"queryTopic";
NSString * const MXcommandGetTags = @"getTags";
NSString * const MXcommandAddTags = @"addTags";
NSString * const MXcommandSetTags = @"setTags";
NSString * const MXcommandFetch = @"fetch";
NSString * const MXctype = @"ctype";
NSString * const MXctypeJSON = @"application/json";

NSString * const kMMXDeviceUUID = @"kMMXDeviceUUID";
NSString * const kMMXAnonPassword = @"kMMXAnonPassword";

NSString * const MMXErrorDomain = @"MMXErrorDomain";

NSInteger  const MXDevRegSuccess = 201;
NSInteger  const MXDevUnregSuccess = 200;

NSInteger  const kMinUsernameLength = 5;
NSInteger  const kMaxUsernameLength = 42;
NSInteger  const kMinPasswordLength = 1;
NSInteger  const kMaxPasswordLength = 32;
NSUInteger const kMaxMessageSize = 2 * 100 * 1024;

NSString * const kMMXXMPPProtocol = @"xmpp";

NSString * const kAddressUsernameKey = @"userId";
NSString * const kAddressDeviceIDKey = @"devId";
NSString * const kAddressDisplayNameKey = @"displayName";

@end
