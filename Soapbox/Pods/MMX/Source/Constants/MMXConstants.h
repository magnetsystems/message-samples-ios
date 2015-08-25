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

@interface MMXConstants : NSObject
extern NSString  * const MXnsAppReg;
extern NSString  * const MXnsDevice;
extern NSString  * const MXnsMsgAck;
extern NSString  * const MXnsDataPayload;
extern NSString  * const MXnsServerSignal;
extern NSString  * const MXnsMsgState;
extern NSString  * const MXnsDeliveryReceipt;
extern NSString  * const MXnsUser;
extern NSString  * const MXnsPubSub;
extern NSString  * const MXmmxElement;
extern NSString  * const MXpayloadElement;
extern NSString  * const MXrequestElement;
extern NSString  * const MXreceivedElement;
extern NSString  * const MXmetaElement;
extern NSString  * const MXmmxMetaElement;
extern NSString  * const MXosType;
extern NSString  * const MXcommandString;
extern NSString  * const MXcommandRegister;
extern NSString  * const MXcommandUnregister;
extern NSString  * const MXcommandListTopics;
extern NSString  * const MXcommandGetLatest;
extern NSString  * const MXcommandAck;
extern NSString  * const MXcommandCreate;
extern NSString  * const MXcommandCreateTopic;
extern NSString  * const MXcommandDeleteTopic;
extern NSString  * const MXcommandSubscribe;
extern NSString  * const MXcommandUnsubscribe;
extern NSString  * const MXcommandUnsubscribeForDevice;
extern NSString  * const MXcommandGetSubscribers;
extern NSString  * const MXcommandRetract;
extern NSString  * const MXcommandRetractAll;
extern NSString  * const MXcommandGetSummary;
extern NSString  * const MXcommandQuery;
extern NSString  * const MXcommandQueryTopic;
extern NSString  * const MXcommandGetTags;
extern NSString  * const MXcommandAddTags;
extern NSString  * const MXcommandSetTags;
extern NSString  * const MXcommandFetch;
extern NSString  * const MXctype;
extern NSString  * const MXctypeJSON;

extern NSString  * const kMMXDeviceUUID;
extern NSString  * const kMMXAnonPassword;

extern NSString  * const MMXErrorDomain;

extern NSInteger  const MXDevRegSuccess;
extern NSInteger  const MXDevUnregSuccess;

extern NSString * const kMMXXMPPProtocol;

extern NSString * const kAddressUsernameKey;
extern NSString * const kAddressDeviceIDKey;
extern NSString * const kAddressDisplayNameKey;

extern NSInteger const kMinUsernameLength;
extern NSInteger const kMaxUsernameLength;
extern NSInteger const kMinPasswordLength;
extern NSInteger const kMaxPasswordLength;
extern NSUInteger const kMaxMessageSize;

@end
