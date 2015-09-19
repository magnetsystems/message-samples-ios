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

#import "MMXDeviceManager_Private.h"
#import "MMXDeviceProfile_Private.h"
#import "MMXConstants.h"
#import "MMXConfiguration.h"
#import "MMXDeviceProfile_Private.h"
#import "MMXIQResponse.h"
#import "MMXDeviceQueryResponse.h"
#import "MMXClient_Private.h"
#import "MMXUserID_Private.h"
#import "MMXEndpoint_Private.h"
#import "MMXLogger.h"
#import "XMPP.h"
#import "XMPPStream.h"
#import "XMPPIDTracker.h"
#import "XMPPIQ+MMX.h"
#import "XMPPJID+MMX.h"

#import "MMXUtils.h"

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#else
	#import <SystemConfiguration/SystemConfiguration.h>
#endif

@interface MMXDeviceManager ()

@end

NSString *const kMMXDeviceName = @"kMMXDeviceName";

@implementation MMXDeviceManager

- (instancetype)initWithDelegate:(id<MMXDeviceManagerDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
		_callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class MMXDeviceManager. Use the property from MMXClient."
                                 userInfo:nil];
    return nil;
}

#pragma mark - Device Register/Unregister

- (MMXDeviceProfile *)currentDeviceForUsername:(NSString *)username {
    MMXDeviceProfile *device = [[MMXDeviceProfile alloc] init];
	device.endpoint = [MMXEndpoint endpointWithUsername:username deviceID:[MMXDeviceManager deviceUUID]];
#if TARGET_OS_IPHONE
	device.modelInfo = [UIDevice currentDevice].model;
	device.osVersion = [[UIDevice currentDevice] systemVersion];
	device.osType = MXosType;
#else
	device.modelInfo =  (__bridge id)SCDynamicStoreCopyComputerName(NULL, NULL);
	NSDictionary * sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	if (sv && [sv objectForKey:@"ProductVersion"]) {
		device.osVersion = [sv objectForKey:@"ProductVersion"];
	}
	device.osVersion = @"Unknown OSX";
	device.osType = @"osx";
#endif
    device.apiKey = self.delegate.configuration.apiKey;
    device.displayName = [MMXDeviceManager deviceNameForUsername:username];
    device.pushType = @"APNS";
    if ([self.delegate deviceToken] && ![[self.delegate deviceToken] isEqualToString:@""]) {
        device.pushToken = [self.delegate deviceToken];
    }
    return device;
}

- (XMPPIQ *)deviceRegistationIQ:(MMXDeviceProfile *)device error:(NSError**)error {
    NSMutableDictionary *devRegDictionary = [device dictionaryRepresentation].mutableCopy;
    [devRegDictionary setObject:@(kTempVersionMajor) forKey:@"versionMajor"];
    [devRegDictionary setObject:@(kTempVersionMinor) forKey:@"versionMinor"];
	NSError * parsingError;
    NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:devRegDictionary xmlns:MXnsDevice commandStringValue:MXcommandRegister error:&parsingError];
    if (parsingError) {
		*error = parsingError;
        return nil;
    } else {
        XMPPIQ *devRegIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [devRegIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [devRegIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return devRegIQ;
    }
}

- (void)registerCurrentDeviceWithSuccess:(void (^)(BOOL success))success
                                 failure:(void (^)(NSError * error))failure {
    
    [self registerDevice:[self currentDeviceForUsername:[[self.delegate currentJID] usernameWithoutAppID]] success:success failure:failure];
}

- (void)registerDevice:(MMXDeviceProfile *)device
               success:(void (^)(BOOL success))success
               failure:(void (^)(NSError * error))failure {
    
    NSError * parsingError;
    XMPPIQ *devRegIQ = [self deviceRegistationIQ:device error:&parsingError];
    if (!parsingError) {
        [self.delegate sendIQ:devRegIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
          if (obj) {
                //FIXME: Refactor this!!
                XMPPIQ * iq = (XMPPIQ *)obj;
                if ([iq isErrorIQ]) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Device Registration Failure."]);
					});
                } else {
                    MMXIQResponse *devRegResp = [MMXIQResponse responseFromIQ:iq];
                    NSString* iqId = [iq elementID];
                    [self.delegate stopTrackingIQWithID:iqId];
                    if (devRegResp.code == 200 || devRegResp.code == 201) {
                        if (success) {
							dispatch_async(self.callbackQueue, ^{
								success(YES);
							});
                        }
                    } else {
                        if (failure) {
							dispatch_async(self.callbackQueue, ^{
								failure([iq errorWithTitle:@"Device Registration Failure."]);
							});
                        }
                    }
                }
            }  else {
                NSError *error = [MMXClient errorWithTitle:@"Device Registration Failure." message:@"Something went wrong" code:500];
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure(error);
					});
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    }
}

- (void)deregisterCurrentDeviceWithSuccess:(void (^)(BOOL success))success
                                 failure:(void (^)(NSError * error))failure {
    
    NSDictionary *devRegDictionary = @{@"devId":[MMXDeviceManager deviceUUID]};
    
    NSError *creationError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:devRegDictionary xmlns:MXnsDevice commandStringValue:MXcommandUnregister error:&creationError];
    if (!creationError) {
        XMPPIQ *devRegIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [devRegIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [devRegIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:devRegIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Device Deregistration Failure."]);
					});
                }
            } else {
                MMXIQResponse *devRegResp = [MMXIQResponse responseFromIQ:iq];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (devRegResp.code == 200 || devRegResp.code == 201) {
                    [self.delegate disconnect];
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([devRegResp errorFromResponse:@"Device Deregistration Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(creationError);
			});
        }
    }
}

- (void)setCurrentDeviceName:(NSString*)name
					 success:(void (^)(BOOL))success
					 failure:(void (^)(NSError *))failure {
	if (name == nil || [name isEqualToString:@""]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Device Name" message:@"Device Name cannot be nil or empty string." code:400]);
			});
		}
		return;
	}

	[MMXDeviceManager setDeviceName:name forUsername:[[self.delegate currentJID] usernameWithoutAppID]];
    [self registerCurrentDeviceWithSuccess:success failure:failure];
}

#pragma mark - Query Devices

- (void)currentDeviceProfileWithSuccess:(void (^)(MMXDeviceProfile * device))success
								failure:(void (^)(NSError * error))failure {
	[self deviceProfilesForCurrentUserWithSuccess:^(NSArray *devices) {
		if (success) {
			if (devices.count) {
				NSString * devID = [MMXDeviceManager deviceUUID];
				NSArray * devArray = [NSArray arrayWithArray:devices];
				MMXDeviceProfile * myDevice = nil;
				for (MMXDeviceProfile * dev in devArray) {
					if ([dev.endpoint.deviceID isEqualToString:devID]) {
						myDevice = dev.copy;
					}
				}
				if (success && myDevice) {
					dispatch_async(self.callbackQueue, ^{
						success(myDevice);
					});
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([MMXClient errorWithTitle:@"Error fetching device" message:@"An unknown error occured trying to fetch your device information." code:500]);
						});
					}
				}
			}
		}
	} failure:^(NSError *error) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		}
	}];
}

- (void)devicesForUser:(MMXUserID *)user
			   success:(void (^)(NSArray *))success
			   failure:(void (^)(NSError *))failure {
	
	NSError *creationError;
	NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsDevice];
//	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:username xmlns:MXnsDevice commandStringValue:@"QUERY" error:&creationError];
	[mmxElement addAttributeWithName:MXcommandString stringValue:MXcommandQuery];
	[mmxElement setStringValue:user.username];
	[mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
	if (!creationError) {
		XMPPIQ *devRegIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
		[devRegIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
		[devRegIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		[self.delegate sendIQ:devRegIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Device Query Failure."]);
					});
				}
			} else {
				MMXDeviceQueryResponse *devRegResp = [MMXDeviceQueryResponse responseFromIQ:iq username:user.username];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (devRegResp.code == 200 || devRegResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(devRegResp.devices);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([devRegResp errorFromResponse:@"Device Query Failure"]);
						});
					}
				}
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(creationError);
			});
		}
	}
}

- (void)deviceProfilesForCurrentUserWithSuccess:(void (^)(NSArray *))success
										failure:(void (^)(NSError *))failure {
    NSError *creationError;
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsDevice];
    [mmxElement addAttributeWithName:MXcommandString stringValue:MXcommandQuery];
    [mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
    if (!creationError) {
        XMPPIQ *devRegIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [devRegIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [devRegIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:devRegIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Device Query Failure."]);
					});
                }
            } else {
                MMXDeviceQueryResponse *devRegResp = [MMXDeviceQueryResponse responseFromIQ:iq username:[[self.delegate currentJID] usernameWithoutAppID]];
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (devRegResp.code == 200 || devRegResp.code == 201) {
                    if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(devRegResp.devices.copy);
						});
                    }
                } else {
                    if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([devRegResp errorFromResponse:@"Device Query Failure"]);
						});
                    }
                }
            }
        }];
    } else {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(creationError);
			});
        }
    }
}

#pragma mark - Deactivate Device

- (void)deactivateCurrentDeviceSuccess:(void (^)(BOOL success))success
							   failure:(void (^)(NSError * error))failure {
	NSError * parsingError;
	NSDictionary * dict = @{@"devId":[MMXDeviceManager deviceUUID]};
	//FIXME: Fix commandStringValue when the server side makes them consistent "UNREGISTER" should not be all uppercase
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsDevice commandStringValue:@"UNREGISTER" error:&parsingError];
	if (parsingError) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
		}
	} else {
		XMPPIQ *tagsIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
		[tagsIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
		[tagsIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		[self.delegate sendIQ:tagsIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"Device Deactivation Failure."]);
					});
				}
			} else {
				MMXIQResponse *deactivateResp = [MMXIQResponse responseFromIQ:iq];
				if (deactivateResp.code == 200 || deactivateResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([deactivateResp errorFromResponse:@"Device Deactivation Failure"]);
						});
					}
				}
			}
		}];
	}
}

#pragma mark - Device Tags

- (void)tagsForDevice:(MMXDeviceProfile *)device
              success:(void (^)(NSDate * lastModified, NSArray * tags))success
              failure:(void (^)(NSError * error))failure {
    NSError * parsingError;
    NSDictionary * dict = @{@"devId":device.endpoint.deviceID};
    //FIXME: Fix commandStringValue when the server side makes them consistent "GETTAGS" should not be all uppercase
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsDevice commandStringValue:@"GETTAGS" error:&parsingError];
    if (parsingError) {
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
        }
    } else {
        XMPPIQ *tagsIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [tagsIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [tagsIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:tagsIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Tags Request Failure."]);
					});
                }
            } else {
                NSArray * tagArray;
                NSDate * lastModified;
                NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement xmlns:MXnsDevice];
                if (mmxElement) {
                    NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
                    NSError* error;
                    NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
					if (error) {
						if (failure) {
							dispatch_async(self.callbackQueue, ^{
								failure(error);
							});
						}
					} else {
						if (jsonDictionary[@"tags"] && jsonDictionary[@"tags"] != [NSNull null]) {
							tagArray = jsonDictionary[@"tags"];
						} else {
							tagArray = @[];
						}
						if (jsonDictionary[@"lastModTime"] && jsonDictionary[@"lastModTime"] != [NSNull null]) {
							NSString * dateString = jsonDictionary[@"lastModTime"];
							lastModified = [MMXUtils dateFromiso8601Format:dateString];
						} else {
							lastModified = nil;
						}
					}
                }
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
                if (success) {
					dispatch_async(self.callbackQueue, ^{
						success(lastModified,tagArray);
					});
                }
            }
        }];
    }
}

- (void)addTags:(NSArray *)tags
	  forDevice:(MMXDeviceProfile *)device
		success:(void (^)(BOOL))success
		failure:(void (^)(NSError *))failure {
	[self updateTags:tags updateType:@"ADD" forDevice:device success:success failure:failure];
}

- (void)setTags:(NSArray *)tags
	  forDevice:(MMXDeviceProfile *)device
		success:(void (^)(BOOL))success
		failure:(void (^)(NSError *))failure {
	[self updateTags:tags updateType:@"SET" forDevice:device success:success failure:failure];
}

- (void)removeTags:(NSArray *)tags
		 forDevice:(MMXDeviceProfile *)device
		   success:(void (^)(BOOL))success
		   failure:(void (^)(NSError *))failure {
	[self updateTags:tags updateType:@"REMOVE" forDevice:device success:success failure:failure];
}

- (void)updateTags:(NSArray *)tags
		updateType:(NSString *)updateType
		forDevice:(MMXDeviceProfile *)device
		   success:(void (^)(BOOL))success
		   failure:(void (^)(NSError *))failure {
	if ([updateType isEqualToString:@"ADD"] && (tags == nil || tags.count < 1)) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Tags" message:@"Tags cannot be empty." code:500]);
			});
		}
		return;
	}
	for (NSString * tag in tags) {
		if (![MMXUtils validateTag:tag]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([MMXClient errorWithTitle:@"Invalid Tags" message:@"Tags was either too long or used invalid characters." code:500]);
				});
			}
			return;
		}
	}
	[[MMXLogger sharedLogger] verbose:@"MMXDeviceManager %@Tags:forDevice:. Tags = %@",updateType, tags];
	NSError * parsingError;
	NSDictionary * dict = @{@"devId":device.endpoint.deviceID,@"tags":tags ? tags : @[]};
	//FIXME: Fix commandStringValue when the server side makes them consistent "ADDTAGS" should not be all uppercase
	NSString *commandString = [NSString stringWithFormat:@"%@TAGS",updateType];
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsDevice commandStringValue:commandString error:&parsingError];
	if (parsingError) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(parsingError);
			});
		}
	} else {
		XMPPIQ *tagsIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
		[tagsIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
		[tagsIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		[self.delegate sendIQ:tagsIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:[NSString stringWithFormat:@"%@ Device Tags Failure.",[updateType capitalizedString]]]);
					});
				}
			} else {
				MMXIQResponse *setTagsResp = [MMXIQResponse responseFromIQ:iq];
				if (setTagsResp.code == 200 || setTagsResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([setTagsResp errorFromResponse:[NSString stringWithFormat:@"%@ Device Tags Failure.",[updateType capitalizedString]]]);
						});
					}
				}
			}
		}];
	}
}

- (void)setCurrentDevicePhoneNumber:(NSString *)phoneNumber
                     success:(void (^)(BOOL success))success
                     failure:(void (^)(NSError * error))failure {
	MMXDeviceProfile * device = [self currentDeviceForUsername:[[self.delegate currentJID] usernameWithoutAppID]];
    device.phoneNumber = phoneNumber;
    [self registerDevice:device success:success failure:failure];
}

#pragma mark - Helper Methods

- (NSString *)deviceNameForUsername:(NSString *)username {
    return [MMXDeviceManager deviceNameForUsername:username];
}

+ (void)setDeviceName:(NSString *)deviceName forUsername:(NSString *)username {
	NSString * key = kMMXDeviceName;
	if (username) {
		key = [NSString stringWithFormat:@"%@%@",kMMXDeviceName,username];
	}
	[[NSUserDefaults standardUserDefaults] setObject:deviceName forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceNameForUsername:(NSString *)username {
    //TODO: Temporary functionality to store generated UUID. Create more secure method
	NSString * key = kMMXDeviceName;
	if (username) {
		key = [NSString stringWithFormat:@"%@%@",kMMXDeviceName,username];
	}
    NSString *savedDeviceName = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (savedDeviceName && ![savedDeviceName isEqualToString:@""]) {
        return savedDeviceName;
    }
#if TARGET_OS_IPHONE
	NSString *newDeviceName = [UIDevice currentDevice].name;
#else
	NSString *newDeviceName = (__bridge id)SCDynamicStoreCopyComputerName(NULL, NULL);
#endif
    [[NSUserDefaults standardUserDefaults] setObject:newDeviceName forKey:kMMXDeviceName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return newDeviceName;
}

+ (NSString *)deviceUUID {
    //TODO: Temporary functionality to store generated UUID. Create more secure method
    NSString *savedDeviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kMMXDeviceUUID];
    if (savedDeviceUUID && ![savedDeviceUUID isEqualToString:@""]) {
        return savedDeviceUUID;
    }
    NSString * newDeviceUUID = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:newDeviceUUID forKey:kMMXDeviceUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return newDeviceUUID;
}

#pragma mark - Credentials

+ (NSString*)anonymousUsername {
    return [NSString stringWithFormat:@"_anon-%@",[MMXDeviceManager deviceUUID]];
}

+ (NSString*)anonymousPassword {
	//TODO: Temporary functionality to store generated UUID. Create more secure method
	NSString *savedDeviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kMMXAnonPassword];
	if (savedDeviceUUID && ![savedDeviceUUID isEqualToString:@""]) {
		return savedDeviceUUID;
	}
	NSString * newDeviceUUID = [[NSUUID UUID] UUIDString];
	[[NSUserDefaults standardUserDefaults] setObject:newDeviceUUID forKey:kMMXAnonPassword];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return newDeviceUUID;
}

+ (NSURLCredential *)anonymousCredentials {
	return [NSURLCredential credentialWithUser:[MMXDeviceManager anonymousUsername] password:[MMXDeviceManager anonymousPassword] persistence:NSURLCredentialPersistenceNone];
}

@end
