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
@class MMXDeviceProfile;

/**
 *  MMXDeviceManager is the primary class interacting with devices.
 *	It has many methods for getting and updating the current device's information.
 */
@interface MMXDeviceManager : NSObject

/**
 *  The callback dispatch queue. Value is initially set to the main queue.
 */
@property (nonatomic, assign) dispatch_queue_t callbackQueue;

/**
 *  Get the current device information.
 *
 *  @param success - Block with MMXDeviceProfile object with the current device information.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)currentDeviceProfileWithSuccess:(void (^)(MMXDeviceProfile * device))success
								failure:(void (^)(NSError * error))failure;

/**
 *  Method for getting the list of devices registered to the currently logged in user.
 *
 *  @param success - An NSArray of MMXDeviceProfile objects.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)deviceProfilesForCurrentUserWithSuccess:(void (^)(NSArray * devices))success
										failure:(void (^)(NSError * error))failure;

/**
 *  Method used to update the current device's name
 *
 *  @param name    - The new name you want to set for the device
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)setCurrentDeviceName:(NSString*)name
					 success:(void (^)(BOOL success))success
					 failure:(void (^)(NSError * error))failure;

/**
 *  Method used to set the current device's phone number
 *
 *  @param phoneNumber - The new phone number you want to set for the device
 *  @param success     - Block with BOOL. Value should be YES.
 *  @param failure     - Block with an NSError with details about the call failure.
 */
- (void)setCurrentDevicePhoneNumber:(NSString *)phoneNumber
							success:(void (^)(BOOL success))success
							failure:(void (^)(NSError * error))failure;

/**
 *  Method call to deregister the current device. Deregistering the device means it will not receive any more messages or push notifications.
 *  Client will disconnect as part of a successful call.
 *
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)deregisterCurrentDeviceWithSuccess:(void (^)(BOOL success))success
                                   failure:(void (^)(NSError * error))failure;

/**
 *  Method to get a list of tags associated with a device.
 *
 *  @param device  - The MMXDeviceProfile object for the device you want to get the current tags for. Cannot be nil.
 *  @param success - A block with a NSArray of tags(NSStrings) and an NSDate for the last time the tags were modified.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)tagsForDevice:(MMXDeviceProfile *)device
              success:(void (^)(NSDate * lastModified, NSArray * tags))success
              failure:(void (^)(NSError * error))failure;

/**
 *  Method to add tags to a device.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to add to the device.
 *  @param device  - The MMXDeviceProfile object for the device you want to add tags to. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)addTags:(NSArray *)tags
	  forDevice:(MMXDeviceProfile *)device
		success:(void (^)(BOOL))success
		failure:(void (^)(NSError *))failure;

/**
 *  Set tags for a specific device. This will overwrite ALL existing tags for the device.
 *	This can be used to delete tags by passing in the sub-set of existing tags that you want to keep.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to set for the device.
 *  @param device  - The MMXDeviceProfile object for the device you want to set tags for. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)setTags:(NSArray *)tags
	  forDevice:(MMXDeviceProfile *)device
		success:(void (^)(BOOL))success
		failure:(void (^)(NSError *))failure;

/**
 *  Remove tags for a specific device.
 *
 *  @param tags    - A NSArray of tags(NSStrings) that you want to remove.
 *  @param device  - The MMXDeviceProfile object for the device you want to remove tags from. Cannot be nil.
 *  @param success - Block with BOOL. Value should be YES.
 *  @param failure - Block with an NSError with details about the call failure.
 */
- (void)removeTags:(NSArray *)tags
		 forDevice:(MMXDeviceProfile *)device
		   success:(void (^)(BOOL))success
		   failure:(void (^)(NSError *))failure;

@end
