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


#import "ChannelListCell.h"
#import "UIColor+Soapbox.h"
#import <MMX.h>

@interface ChannelListCell () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@end

@implementation ChannelListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Overriden setters

- (void)setChannel:(MMXChannel *)channel {
    _channel = channel;
    dispatch_async(dispatch_get_main_queue(), ^{
        /*
         *  Extracting the topic name using the MMXTopic topicName property
         */
        
        self.topicLabel.text = _channel.name;
    });
    
    [self setupBadge];
    [self updateBadge:_channel.numberOfMessages];
}

//- (void)setTopicSummary:(MMXTopicSummary *)topicSummary isSubscribed:(BOOL)isSubscribed {
//
//	self.topicSummary = topicSummary;
//	self.isSubscribed = isSubscribed;
//	
//	dispatch_async(dispatch_get_main_queue(), ^{
//		/*
//		 *  Extracting the topic name using the MMXTopic topicName property
//		 */
//
//		self.topicLabel.text = self.topicSummary.topic.topicName;
//	});
//	
//	[self setupBadge];
//	[self updateBadge:self.topicSummary.numItemsPublished];
//}

- (void)setupBadge {
	self.badgeLabel.hidden = YES;
	self.badgeLabel.adjustsFontSizeToFitWidth = YES;
	self.badgeLabel.numberOfLines = 0;
	self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.height / 2.0;
	self.badgeLabel.backgroundColor = [UIColor soapboxNewMessagesBadge];
	self.badgeLabel.clipsToBounds = YES;
}

- (void)updateBadge:(int)badgeCount {
	if (badgeCount > 0) {
		self.badgeLabel.text = [NSString stringWithFormat:@"%@  ",[@(badgeCount) stringValue]];
		self.badgeLabel.hidden = NO;
	} else {
		self.badgeLabel.text = @"";
		self.badgeLabel.hidden = YES;
	}
}

- (void)prepareForReuse {
	self.channel = nil;
	self.topicLabel.text = @"";
	self.badgeLabel.text = @"";
}

@end
