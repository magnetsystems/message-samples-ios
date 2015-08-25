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


#import "PubSubCell.h"
#import "SoapboxUtils.h"
#import "Announcement.h"
#import <MMX/MMX.h>

@interface PubSubCell ()

@property (nonatomic, strong) MMXMessage *message;
@property (nonatomic, strong) NSString *senderUsername;
@property (nonatomic, strong) UIColor *contentBackgroundColor;
@property (nonatomic, assign) BOOL isCurrentUser;

@end

const float kPubSubCellFontSize = 12.0;
const float kPubSubCellLabelWidthPercentage = 0.8;
const float kPubSubCellLabelOffsetPercentage = 0.02;

@implementation PubSubCell

#pragma mark - UITableViewCell Methods
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
	self.message = nil;
	for (UIView * subView in [self.contentView subviews]) {
		[subView removeFromSuperview];
	}
}

#pragma mark - Customize Cell Methods
- (void)setMessage:(MMXMessage *)message isCurrentUser:(BOOL)isCurrentUser color:(UIColor *)color {
	self.message = message;
	self.isCurrentUser = isCurrentUser;
	self.contentBackgroundColor = color;
	[self extractSenderUsername];
	[self setupLabels];
}

- (void)extractSenderUsername {
	/*
	 *  Extract username from MMXPubSubMessage metaData property
	 *  By default the PubSub is anonymous and MMXPubSubMessage does not include the sender's username
	 */
	NSString *senderUserName = self.message.sender.username;
	if (self.isCurrentUser) {
		senderUserName = @"Me";
	} else if (senderUserName == nil || [senderUserName isEqualToString:@""]) {
		senderUserName = @"Unknown";
	}
	self.senderUsername = senderUserName;
}

- (void)setupLabels {
	CGFloat offset = self.contentView.frame.size.width * kPubSubCellLabelOffsetPercentage;
	CGFloat width = self.contentView.frame.size.width * kPubSubCellLabelWidthPercentage;
	UILabel * contentLabel = [PubSubCell contentLabelForMessage:self.message cellWidth:self.contentView.frame.size.width];
	contentLabel.frame = CGRectMake(offset/2.0, offset/2.0, contentLabel.frame.size.width, contentLabel.frame.size.height);
	CGRect contentFrame = CGRectMake(offset, offset, width + offset, contentLabel.frame.size.height + offset);
	
	if (self.isCurrentUser) {
		CGFloat newXOffset = self.contentView.frame.size.width - (width + offset) - offset;
		contentFrame = CGRectMake(newXOffset, offset, width + offset, contentLabel.frame.size.height + offset);
	}
	
	UILabel * subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentFrame.origin.x, contentFrame.size.height + offset * 1.5, contentFrame.size.width, kPubSubCellFontSize)];
	NSMutableAttributedString *attributedDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - ",self.senderUsername] attributes:@{NSFontAttributeName:[PubSubCell boldFont]}];
	NSString *dateString = [[SoapboxUtils friendlyDateFormatter] stringFromDate:self.message.timestamp];
	[attributedDescription appendAttributedString:[[NSMutableAttributedString alloc] initWithString:dateString attributes:@{NSFontAttributeName:[PubSubCell regularFont]}]];
	subTitleLabel.attributedText = attributedDescription;
	contentLabel.textAlignment = NSTextAlignmentJustified;
	if (self.isCurrentUser) {
		subTitleLabel.textAlignment = NSTextAlignmentRight;
	} else {
		subTitleLabel.textAlignment = NSTextAlignmentLeft;
	}
	UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
	contentView.backgroundColor = self.contentBackgroundColor;
	[contentView addSubview:contentLabel];
	[self.contentView addSubview:contentView];
	[self.contentView addSubview:subTitleLabel];
}

+ (UILabel *)contentLabelForMessage:(MMXMessage *)message cellWidth:(float)width {
	UIFont *font = [PubSubCell regularFont];
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width * kPubSubCellLabelWidthPercentage, 20000.0f)];
	label.font = font;
	label.numberOfLines = 0;
	
	/*
	 *  Extract message content from MMXPubSubMessage messageContent property
	 */
    NSError *error;
    Announcement *announcement = [MTLJSONAdapter modelOfClass:[Announcement class] fromJSONDictionary:message.messageContent error:&error];
    if (!error) {
        // FIXME:
        label.text = announcement.content ? : @"Message sent from v1";

        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGRect boundingBox = [label.text boundingRectWithSize:label.frame.size
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:context];

        label.frame = boundingBox;
    }

	return label;
}

+ (CGSize)sizeOfContentLabelForMessage:(MMXMessage *)message cellWidth:(float)width {
	
	UILabel * label = [PubSubCell contentLabelForMessage:message cellWidth:width];
	return label.frame.size;
}

+ (CGFloat)estimatedHeightForMessage:(MMXMessage *)message cellWidth:(float)width {
	CGFloat height = [PubSubCell sizeOfContentLabelForMessage:message cellWidth:width].height;
	return height + width * kPubSubCellLabelOffsetPercentage * 3.5 + kPubSubCellFontSize;
}

#pragma mark - Fonts

+ (UIFont *)regularFont {
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:kPubSubCellFontSize];
	return font;
}

+ (UIFont *)boldFont {
	UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:kPubSubCellFontSize];
	return font;
}

@end
