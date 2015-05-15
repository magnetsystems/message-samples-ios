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

@interface AvailablePlayersTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiesLabel;
@property (nonatomic, strong, readwrite) RPSLSUser * user;

@end

@implementation AvailablePlayersTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserForCell:(RPSLSUser *)user {
	self.user = user;
	self.playerNameLabel.text = self.user.username;
	self.winsLabel.text = [NSString stringWithFormat:@"W=%lu",(unsigned long)self.user.stats.wins];
	self.lossesLabel.text = [NSString stringWithFormat:@"L=%lu",(unsigned long)self.user.stats.losses];
	self.tiesLabel.text = [NSString stringWithFormat:@"T=%lu",(unsigned long)self.user.stats.ties];
}

- (void)prepareForReuse {
	self.user = nil;
	self.playerNameLabel.text = @"";
	self.winsLabel.text = @"";
	self.lossesLabel.text = @"";
	self.tiesLabel.text = @"";
}

@end
