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


#import "MessageTextView.h"

@implementation MessageTextView

- (instancetype)init
{
	if (self = [super init]) {
		// Do something
	}
	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	self.backgroundColor = [UIColor whiteColor];
	
	self.placeholder = NSLocalizedString(@"Message", nil);
	self.placeholderColor = [UIColor lightGrayColor];
	self.pastableMediaTypes = SLKPastableMediaTypeNone;
	
	self.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
	self.layer.shouldRasterize = YES;
	self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
