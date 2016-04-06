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

@import MagnetMaxCore;

@class MMXClient,MMXChannel,MMUser;

@interface MMXWhitelistOperation : MMAsynchronousOperation
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, weak, readonly) MMXClient *client;
@property (nonatomic, readonly) NSArray<MMUser*>* users;
@property (nonatomic, assign, readonly) BOOL makeMember;

- (instancetype)init:(MMXClient *)client channel:(MMXChannel *)channel users:(NSArray<MMUser*>*)users makeMember:(BOOL)makeMember completion : (void (^) (NSError * __nullable error)) completion;
NS_ASSUME_NONNULL_END
@end
