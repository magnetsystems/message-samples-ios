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

#import "RPSLSConstants.h"

@implementation RPSLSConstants

NSString * const kPostStatus_Available = @"AVAILABLE";
NSString * const kPostStatus_NotAvailable = @"NOTAVAILABLE";

NSString * const kPostStatus_TopicName = @"availableplayers";

NSString * const kMessageKey_Username = @"username";
NSString * const kMessageKey_Wins = @"wins";
NSString * const kMessageKey_Losses = @"losses";
NSString * const kMessageKey_Ties = @"ties";
NSString * const kMessageKey_UserAvailablity = @"isAvailable";
NSString * const kMessageKey_Type = @"type";
NSString * const kMessageKey_Result = @"isAccept";
NSString * const kMessageKey_GameID = @"gameId";
NSString * const kMessageKey_Choice = @"choice";
NSString * const kMessageKey_Timestamp = @"timestamp";

NSString * const kLocalSaveKey_Wins = @"kLocalSaveKeyWins";
NSString * const kLocalSaveKey_Losses = @"kLocalSaveKeyLosses";
NSString * const kLocalSaveKey_Ties = @"kLocalSaveKeyTies";
NSString * const kLocalSaveKey_Username = @"kLocalSaveKeyUsername";
NSString * const kLocalSaveKey_Password = @"kLocalSaveKeyPassword";

NSString * const kLocalSaveKey_Rock = @"kLocalSaveKey_Rock";
NSString * const kLocalSaveKey_Paper = @"kLocalSaveKey_Paper";
NSString * const kLocalSaveKey_Scissors = @"kLocalSaveKey_Scissors";
NSString * const kLocalSaveKey_Lizard = @"kLocalSaveKey_Lizard";
NSString * const kLocalSaveKey_Spock = @"kLocalSaveKey_Spock";

NSString * const kMessageTypeValue_Availability = @"AVAILABILITY";
NSString * const kMessageTypeValue_Invite = @"INVITATION";
NSString * const kMessageTypeValue_Accept = @"ACCEPTANCE";
NSString * const kMessageTypeValue_Choice = @"CHOICE";

NSString * const kMessageResultValue_Accept = @"ACCEPT";
NSString * const kMessageResultValue_Reject = @"REJECT";

NSString * const kValueKey_Rock = @"ROCK";
NSString * const kValueKey_Paper = @"PAPER";
NSString * const kValueKey_Scissors = @"SCISSORS";
NSString * const kValueKey_Lizard = @"LIZARD";
NSString * const kValueKey_Spock = @"SPOCK";

int const kAvailableTimeFrame = -60 * 10;


@end
