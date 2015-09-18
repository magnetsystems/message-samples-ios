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

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

/**
 *  The MMXMessageOptions class represents the different options that can be set when sending a message. 
 *	While currently very limited, over time this class will include more options.
 */
@interface MMXMessageOptions : MTLModel

/**
 * If this property is set to YES the receiver is notified that they should send a delivery receipt.
 * Defaults to NO.
 */
@property (nonatomic, assign) BOOL shouldRequestDeliveryReceipt;

@end
