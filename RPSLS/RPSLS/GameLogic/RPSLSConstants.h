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

@interface RPSLSConstants : NSObject

extern NSString * const kPostStatus_Available;
extern NSString * const kPostStatus_NotAvailable;

extern NSString * const kPostStatus_ChannelName;

extern NSString * const kMessageKey_Username;
extern NSString * const kMessageKey_Wins;
extern NSString * const kMessageKey_Losses;
extern NSString * const kMessageKey_Ties;
extern NSString * const kMessageKey_UserAvailablity;
extern NSString * const kMessageKey_Type;
extern NSString * const kMessageKey_Result;
extern NSString * const kMessageKey_GameID;
extern NSString * const kMessageKey_Choice;
extern NSString * const kMessageKey_Timestamp;

extern NSString * const kLocalSaveKey_Wins;
extern NSString * const kLocalSaveKey_Losses;
extern NSString * const kLocalSaveKey_Ties;
extern NSString * const kLocalSaveKey_Username;
extern NSString * const kLocalSaveKey_Password;

extern NSString * const kLocalSaveKey_Rock;
extern NSString * const kLocalSaveKey_Paper;
extern NSString * const kLocalSaveKey_Scissors;
extern NSString * const kLocalSaveKey_Lizard;
extern NSString * const kLocalSaveKey_Spock;

extern NSString * const kMessageTypeValue_Availability;
extern NSString * const kMessageTypeValue_Invite;
extern NSString * const kMessageTypeValue_Accept;
extern NSString * const kMessageTypeValue_Choice;

extern NSString * const kMessageResultValue_Accept;
extern NSString * const kMessageResultValue_Reject;

extern NSString * const kValueKey_Rock;
extern NSString * const kValueKey_Paper;
extern NSString * const kValueKey_Scissors;
extern NSString * const kValueKey_Lizard;
extern NSString * const kValueKey_Spock;

extern int const kAvailableTimeFrame;

@end
