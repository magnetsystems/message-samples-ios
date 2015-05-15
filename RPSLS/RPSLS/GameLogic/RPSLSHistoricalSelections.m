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

#import "RPSLSHistoricalSelections.h"
#import "RPSLSConstants.h"

@interface RPSLSHistoricalSelections ()

@property (nonatomic, assign) NSUInteger rock;
@property (nonatomic, assign) NSUInteger paper;
@property (nonatomic, assign) NSUInteger scissors;
@property (nonatomic, assign) NSUInteger lizard;
@property (nonatomic, assign) NSUInteger spock;

@end

@implementation RPSLSHistoricalSelections

+ (instancetype)myHistoricalSelections {
	RPSLSHistoricalSelections *selections = [[RPSLSHistoricalSelections alloc] init];
	selections.rock = [RPSLSHistoricalSelections myRock];
	selections.paper = [RPSLSHistoricalSelections myPaper];
	selections.scissors = [RPSLSHistoricalSelections myScissors];
	selections.lizard = [RPSLSHistoricalSelections myLizard];
	selections.spock = [RPSLSHistoricalSelections mySpock];
	return selections;
}

#pragma mark - Calculate Percentages
- (float)rockPercentage {
	return self.rock / ([self totalSelections] * 1.0 );
}

- (float)paperPercentage {
	return self.paper / ([self totalSelections] * 1.0 );
}

- (float)scissorsPercentage {
	return self.scissors / ([self totalSelections] * 1.0 );
}

- (float)lizardPercentage {
	return self.lizard / ([self totalSelections] * 1.0 );
}

- (float)spockPercentage {
	return self.spock / ([self totalSelections] * 1.0 );
}

- (int)totalSelections {
	return (int)(self.rock + self.paper + self.scissors + self.lizard + self.spock);
}

//FIXME: Update to save opbject to disk and not use NSUserDefaults
#pragma mark - My Historical Selections
+ (NSUInteger)myRock {
	NSUInteger rock = [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalSaveKey_Rock] integerValue];
	return rock ?: 0;
}

+ (NSUInteger)myPaper {
	NSUInteger paper = [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalSaveKey_Paper] integerValue];
	return paper ?: 0;
}

+ (NSUInteger)myScissors {
	NSUInteger scissors = [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalSaveKey_Scissors] integerValue];
	return scissors ?: 0;
}

+ (NSUInteger)myLizard {
	NSUInteger lizard = [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalSaveKey_Lizard] integerValue];
	return lizard ?: 0;
}

+ (NSUInteger)mySpock {
	NSUInteger spock = [[[NSUserDefaults standardUserDefaults] objectForKey:kLocalSaveKey_Spock] integerValue];
	return spock ?: 0;
}

#pragma mark - Update Historical Selections
+ (void)incrementMyRock {
	[[NSUserDefaults standardUserDefaults] setObject:@([self myRock] + 1) forKey:kLocalSaveKey_Rock];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMyPaper {
	[[NSUserDefaults standardUserDefaults] setObject:@([self myPaper] + 1) forKey:kLocalSaveKey_Paper];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMyScissors {
	[[NSUserDefaults standardUserDefaults] setObject:@([self myScissors] + 1) forKey:kLocalSaveKey_Scissors];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMyLizard {
	[[NSUserDefaults standardUserDefaults] setObject:@([self myLizard] + 1) forKey:kLocalSaveKey_Lizard];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)incrementMySpock {
	[[NSUserDefaults standardUserDefaults] setObject:@([self mySpock] + 1) forKey:kLocalSaveKey_Spock];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end
