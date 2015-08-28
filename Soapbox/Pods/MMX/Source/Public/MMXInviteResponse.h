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

#import <Mantle/Mantle.h>
@class MMXUser;
@class MMXChannel;

@interface MMXInviteResponse : MTLModel

/**
 *  Time the response was sent
 */
@property (nonatomic, readonly) NSDate *timestamp;

/**
 *  A custom message from the sender
 */
@property (nonatomic, readonly) NSString *comments;

/**
 *  The user that sent the response
 */
@property (nonatomic, readonly) MMXUser *sender;

/**
 *  The channel the invite is for.
 */
@property (nonatomic, readonly) MMXChannel *channel;

/**
 *  The response to the invite.
 */
@property (nonatomic, readonly) BOOL accepted;

@end
