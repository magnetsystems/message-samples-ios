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


#import "TopicListCell.h"
#import "UIColor+Soapbox.h"
#import <MMX.h>

@interface TopicListCell () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@end

@implementation TopicListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTopic:(MMXTopic *)topic isSubscribed:(BOOL)isSubscribed {
	
	self.topic = topic;
	self.isSubscribed = isSubscribed;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		/*
		 *  Extracting the topic name using the MMXTopic topicName property
		 */

		self.topicLabel.text = self.topic.topicName;
	});
	
	[self setupBadge];
	[self fetchSummary];
}

- (void)setupBadge {
	self.badgeLabel.hidden = YES;
	self.badgeLabel.adjustsFontSizeToFitWidth = YES;
	self.badgeLabel.numberOfLines = 0;
	self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.height / 2.0;
	self.badgeLabel.backgroundColor = [UIColor soapboxNewMessagesBadge];
	self.badgeLabel.clipsToBounds = YES;
}

- (void)fetchSummary {
	if (self.topic && ![self.topic.topicName isEqualToString:@""]) {
		/*
		 *  Fetching the summary for the last 24 hours of the topic. In a typical app you would not want to make this call here since it will make one call to summaryOfTopics for each topic displayed. Instead you can pass an array of MMXTopic objects that you are interested in and it will return an array of MMXTopicSummary objects.
		 */
		[[MMXClient sharedClient].pubsubManager summaryOfTopics:@[self.topic] since:[[NSDate date]dateByAddingTimeInterval:-60*60*24] until:[NSDate date] success:^(NSArray *summaries) {
			if (summaries.count) {
				/*
				 *  Extracting the number of items publish to the topic in the timeframe specified using the MMXTopicSummary numItemsPublished property
				 */

				MMXTopicSummary * sum = summaries.firstObject;
				[self updateBadge:sum.numItemsPublished];
			}
		} failure:^(NSError *error) {
			NSLog(@"Topic summary failure. Error = %@",error);
		}];
	}
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
	self.topic = nil;
	self.topicLabel.text = @"";
	self.badgeLabel.text = @"";
}

@end
