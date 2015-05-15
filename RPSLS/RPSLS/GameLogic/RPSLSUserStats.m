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

#import "RPSLSUserStats.h"
#import "RPSLSHistoricalSelections.h"
#import "RPSLSConstants.h"
#import "RPSLSUser.h"

@implementation RPSLSUserStats

#pragma mark -

+ (instancetype)statsFromMetaData:(NSDictionary *)metaData {
	RPSLSUserStats * stats = [[RPSLSUserStats alloc] init];
	stats.wins = [self intFromID:metaData[kMessageKey_Wins]];
	stats.losses = [self intFromID:metaData[kMessageKey_Losses]];
	stats.ties = [self intFromID:metaData[kMessageKey_Ties]];
	return stats;
}

- (NSUInteger)wins {
	return _wins ?: 0;
}

- (NSUInteger)losses {
	return _losses ?: 0;
}

- (NSUInteger)ties {
	return _ties ?: 0;
}

+ (NSNumberFormatter *)formatter {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	return numberFormatter;
}

+ (NSUInteger)intFromID:(id)obj {
	if (obj && obj != [NSNull null]) {
		if ([obj isKindOfClass:[NSNumber class]]) {
			return [obj integerValue];
		} else if ([obj isKindOfClass:[NSString class]]) {
			return [[[self formatter] numberFromString:(NSString *)obj] integerValue];
		}
	}
	return 0;
}

//FIXME: Update to save opbject to disk and not use NSUserDefaults
#pragma mark - My(current user) Stats

+ (instancetype)myStats {
	RPSLSUserStats * stats = [[RPSLSUserStats alloc] init];
	stats.wins = [self myWins];
	stats.losses = [self myLosses];
	stats.ties = [self myTies];
	return stats;
}

+ (NSUInteger)myWins {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Wins];
	NSUInteger wins = [[[NSUserDefaults standardUserDefaults] objectForKey:key] integerValue];
	return wins ?: 0;
}

+ (NSUInteger)myLosses {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Losses];
	NSUInteger losses = [[[NSUserDefaults standardUserDefaults] objectForKey:key] integerValue];
	return losses ?: 0;
}

+ (NSUInteger)myTies {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Ties];
	NSUInteger ties = [[[NSUserDefaults standardUserDefaults] objectForKey:key] integerValue];
	return ties ?: 0;
}

+ (void)incrementMyWins {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Wins];
	[[NSUserDefaults standardUserDefaults] setObject:@([self myWins] + 1) forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMyLosses {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Losses];
	[[NSUserDefaults standardUserDefaults] setObject:@([self myLosses] + 1) forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMyTies {
	NSString *key = [NSString stringWithFormat:@"%@%@",[RPSLSUser myUsername],kLocalSaveKey_Ties];
	[[NSUserDefaults standardUserDefaults] setObject:@([self myTies] + 1) forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
