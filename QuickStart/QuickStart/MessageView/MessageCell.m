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


#import "MessageCell.h"
#import "QuickStartUtils.h"
#import <MMX/MMX.h>

@interface MessageCell ()

@property (nonatomic, copy) NSString *senderUsername;
@property (nonatomic, copy) NSString *messageContent;
@property (nonatomic, copy) NSString *timestampString;
@property (nonatomic, copy) UIColor *contentBackgroundColor;
@property (nonatomic, assign) BOOL isOutboundMessage;

@end

const float kMessageCellFontSize = 12.0;
const float kMessageCellLabelWidthPercentage = 0.8;
const float kMessageCellLabelOffsetPercentage = 0.02;

@implementation MessageCell

#pragma mark - UITableViewCell Methods
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
	for (UIView * subView in [self.contentView subviews]) {
		[subView removeFromSuperview];
	}
}

#pragma mark - Customize Cell Methods
- (void)setMessageContent:(NSString *)messageContent
		   senderUsername:(NSString *)senderUsername
		  timestampString:(NSString *)timestampString
		isOutboundMessage:(BOOL)isOutboundMessage
					color:(UIColor *)color {
	
	self.senderUsername = senderUsername;
	self.messageContent = messageContent;
	self.timestampString = timestampString;

	self.isOutboundMessage = isOutboundMessage;
	self.contentBackgroundColor = color;
	[self setupLabels];
}

- (void)setupLabels {
	CGFloat offset = self.contentView.frame.size.width * kMessageCellLabelOffsetPercentage;
	CGFloat width = self.contentView.frame.size.width * kMessageCellLabelWidthPercentage;
	UILabel * contentLabel = [MessageCell contentLabelForMessageContent:self.messageContent cellWidth:self.contentView.frame.size.width];
	contentLabel.frame = CGRectMake(offset/2.0, offset/2.0, contentLabel.frame.size.width, contentLabel.frame.size.height);
	CGRect contentFrame = CGRectMake(offset, offset, width + offset, contentLabel.frame.size.height + offset);
	
	if (self.isOutboundMessage) {
		CGFloat newXOffset = self.contentView.frame.size.width - (width + offset) - offset;
		contentFrame = CGRectMake(newXOffset, offset, width + offset, contentLabel.frame.size.height + offset);
	}
	
	UILabel * subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentFrame.origin.x, contentFrame.size.height + offset * 1.5, contentFrame.size.width, kMessageCellFontSize)];
	NSMutableAttributedString *attributedDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - ",self.senderUsername] attributes:@{NSFontAttributeName:[MessageCell boldFont]}];
	NSString *dateString = self.timestampString;
	[attributedDescription appendAttributedString:[[NSMutableAttributedString alloc] initWithString:dateString attributes:@{NSFontAttributeName:[MessageCell regularFont]}]];
	subTitleLabel.attributedText = attributedDescription;
	contentLabel.textAlignment = NSTextAlignmentJustified;
	if (self.isOutboundMessage) {
		subTitleLabel.textAlignment = NSTextAlignmentRight;
	} else {
		subTitleLabel.textAlignment = NSTextAlignmentLeft;
	}
	UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
	contentView.backgroundColor = self.contentBackgroundColor;
	contentView.layer.cornerRadius = 5.0;
	[contentView addSubview:contentLabel];
	[self.contentView addSubview:contentView];
	[self.contentView addSubview:subTitleLabel];
}

+ (UILabel *)contentLabelForMessageContent:(NSString *)messageContent cellWidth:(float)width {
	UIFont *font = [MessageCell regularFont];
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width * kMessageCellLabelWidthPercentage, 20000.0f)];
	label.font = font;
	label.numberOfLines = 0;
	
	label.text = messageContent;
	
	NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
	CGRect boundingBox = [label.text boundingRectWithSize:label.frame.size
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:font}
												  context:context];

	label.frame = boundingBox;
	return label;
}

+ (CGSize)sizeOfContentLabelForMessageContent:(NSString *)messageContent cellWidth:(float)width {
	
	UILabel * label = [MessageCell contentLabelForMessageContent:messageContent cellWidth:width];
	return label.frame.size;
}

+ (CGFloat)estimatedHeightForMessageContent:(NSString *)messageContent cellWidth:(float)width {
	CGFloat height = [MessageCell sizeOfContentLabelForMessageContent:messageContent cellWidth:width].height;
	return height + width * kMessageCellLabelOffsetPercentage * 3.5 + kMessageCellFontSize;
}

#pragma mark - Fonts

+ (UIFont *)regularFont {
	UIFont * font = [UIFont fontWithName:@"Helvetica" size:kMessageCellFontSize];
	return font;
}

+ (UIFont *)boldFont {
	UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:kMessageCellFontSize];
	return font;
}

@end
