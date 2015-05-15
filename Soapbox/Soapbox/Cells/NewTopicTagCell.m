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


#import "NewTopicTagCell.h"
#import "UIColor+Soapbox.h"

@interface NewTopicTagCell ()
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (nonatomic, readwrite) NSString *tagName;

@end

@implementation NewTopicTagCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCellWithName:(NSString *)name {
	self.tagName = name;
	self.tagNameLabel.text = self.tagName;
	self.selectedLabel.layer.cornerRadius = self.selectedLabel.frame.size.width / 2.0;
	self.selectedLabel.layer.borderWidth = 1.0;
	self.selectedLabel.layer.borderColor = [UIColor soapboxTagsSelectionBadge].CGColor;
	self.selectedLabel.clipsToBounds = YES;

}

- (void)updateSelection {
	if (self.isSelected) {
		self.selectedLabel.text = @"✔︎";
		self.selectedLabel.backgroundColor = [UIColor soapboxTagsSelectionBadge];
	} else {
		self.selectedLabel.text = @"";
		self.selectedLabel.backgroundColor = [UIColor whiteColor];
	}
}

@end
