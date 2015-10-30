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

#import "AvailablePlayersTableViewCell.h"
#import "RPSLSUser.h"
#import "RPSLSUserStats.h"
@import MagnetMaxCore;

@interface AvailablePlayersTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statsLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentLabel;

@property (nonatomic, strong, readwrite) RPSLSUser * user;

@end

@implementation AvailablePlayersTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)showSent {
	self.sentLabel.alpha = 1.0;
	[UIView animateWithDuration:1.2f
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.sentLabel.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
					 }];
}

- (void)setUserForCell:(RPSLSUser *)user {
	self.user = user;
	self.playerNameLabel.text = self.user.messageUserObject.userName;
	
	self.statsLabel.text = [NSString stringWithFormat:@"W=%lu L=%lu T=%lu",(unsigned long)self.user.stats.wins,(unsigned long)self.user.stats.losses,(unsigned long)self.user.stats.ties];
}

- (void)prepareForReuse {
	self.user = nil;
	self.playerNameLabel.text = @"";
	self.statsLabel.text = @"";
}

@end
