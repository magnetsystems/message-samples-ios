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

#import "RPSLSEngine.h"
#import "RPSLSConstants.h"

@implementation RPSLSEngine

#pragma mark - RPSLS Logic

+ (NSString *)resultAsString:(RPSLSResult)result {
	switch (result) {
		case RPSLSResultTie:
			return @"You tied";
			break;
		case RPSLSResultWin:
			return @"You won!";
			break;
		case RPSLSResultLoss:
			return @"You lost!";
			break;
		default:
			return @"Something went wrong!!!";
			break;
	}
}

+ (NSArray *)resultMatrix {
	return @[@[@0, @1, @2, @2, @1],
			 @[@2, @0, @1, @1, @2],
			 @[@1, @2, @0, @2, @1],
			 @[@1, @2, @1, @0, @2],
			 @[@2, @1, @2, @1, @0]];
}

+ (RPSLSResult)myResult:(RPSLSValue)me them:(RPSLSValue)them {
	return (RPSLSResult)[[RPSLSEngine resultMatrix][me][them] intValue];
}

+ (RPSLSValue)stringToValue:(NSString *)valueString {
	if ([valueString isEqualToString:kValueKey_Rock]) {
		return RPSLSValueRock;
	} else if ([valueString isEqualToString:kValueKey_Paper]) {
		return RPSLSValuePaper;
	} else if ([valueString isEqualToString:kValueKey_Scissors]) {
		return RPSLSValueScissors;
	} else if ([valueString isEqualToString:kValueKey_Lizard]) {
		return RPSLSValueLizard;
	} else if ([valueString isEqualToString:kValueKey_Spock]) {
		return RPSLSValueSpock;
	} else {
		return RPSLSValueNotSet;
	}
}

+ (NSString *)valueToString:(RPSLSValue)value {
	switch (value) {
		case RPSLSValueRock:
			return kValueKey_Rock;
			break;
		case RPSLSValuePaper:
			return kValueKey_Paper;
			break;
		case RPSLSValueScissors:
			return kValueKey_Scissors;
			break;
		case RPSLSValueLizard:
			return kValueKey_Lizard;
			break;
		case RPSLSValueSpock:
			return kValueKey_Spock;
			break;
		default:
			return @"";
			break;
	}
}

+ (NSDictionary *)verbMap {
	return @{@"rock": @{@"lizard": @"crushes", @"scissors": @"crushes"},
			 @"paper": @{@"spock": @"disproves", @"rock": @"covers"},
			 @"scissors": @{@"paper": @"cuts", @"lizard": @"decapitates"},
			 @"lizard": @{@"spock": @"poisons", @"paper": @"eats"},
			 @"spock": @{@"scissors": @"smashes", @"rock": @"vaporizes"}};
}

+ (NSString *)verbFromWinner:(RPSLSValue)winner
					   loser:(RPSLSValue)loser {
	NSDictionary * mappingDict = [RPSLSEngine verbMap];
	NSString * winnerString = [self valueToString:winner].lowercaseString;
	NSString * loserString = [RPSLSEngine valueToString:loser].lowercaseString;
	return mappingDict[winnerString][loserString];
}

@end
