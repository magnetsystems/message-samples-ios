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

#import "MMXAccountManager.h"
#import "MMXAccountManager_Private.h"

#import "MMXConstants.h"
#import "MMXIQResponse.h"
#import "MMXUserProfile_Private.h"
#import "MMXQuery_Private.h"
#import "MMXUserQueryResponse.h"
#import "MMXUserQueryResponse_Private.h"
#import "MMXLogger.h"
#import "MMXClient_Private.h"
#import "MMXDeviceManager_Private.h"
#import "MMXEndpoint_Private.h"
#import "MMXDeviceProfile_Private.h"
#import "MMXUser.h"

#import "XMPP.h"
#import "XMPPIQ+MMX.h"
#import "XMPPJID+MMX.h"

#import "MMXUtils.h"
#import "MMXConfiguration.h"
#import "NSString+XEP_0106.h"

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#else
	#import <SystemConfiguration/SystemConfiguration.h>
#endif

@implementation MMXAccountManager

- (instancetype)initWithDelegate:(id<MMXAccountManagerDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
		_callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class MMXAccountManager. Use the property from MMXClient."
                                 userInfo:nil];
    return nil;
}

#pragma mark - Register User

- (void)registerUser:(MMXUserProfile*)user
			password:(NSString *)password
			 success:(void (^)(BOOL success))success
			 failure:(void (^)(NSError * error))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager registerUser. User = %@", user];
	if (![MMXClient validateCharacterSet:user.userID.username]) {
		NSError * error = [MMXClient errorWithTitle:@"Invalid Characters" message:@"There are invalid characters used in the login information provided." code:400];
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		}
		return;
	}
	if (user.userID.username.length > kMaxUsernameLength || user.userID.username.length < kMinUsernameLength || password.length > kMaxPasswordLength || password.length < kMinPasswordLength) {
		NSError * error = [MMXClient errorWithTitle:@"Invalid Character Count" message:@"There is an invalid length of characters used in the login information provided." code:400];
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		}
		return;
	}
	NSError * iqError;
	XMPPIQ *userIQ = [self registrationIQForUser:user createMode:@"UPGRADE_USER" password:password error:&iqError];
	if (userIQ) {
		[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Registration Failure."]);
					});
				}
			} else {
				MMXIQResponse *createUserResp = [MMXIQResponse responseFromIQ:iq];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (createUserResp.code == 200 || createUserResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([createUserResp errorFromResponse:@"User Registration Failure"]);
						});
					}
				}
			}
		}];
	} else {
		if (failure && iqError) {
			dispatch_async(self.callbackQueue, ^{
				failure(iqError);
			});
		}
	}
}

- (void)createAccountForUsername:(NSString *)username
					 displayName:(NSString *)displayName
						   email:(NSString *)email
						password:(NSString *)password
						 success:(void (^)(MMXUserProfile *userProfile))success
						 failure:(void (^)(NSError * error))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager createAccountForUsername. Username = %@", username];
    if (![MMXClient validateCharacterSet:username]) {
        NSError * error = [MMXClient errorWithTitle:@"Invalid Characters" message:@"There are invalid characters used in the login information provided." code:400];
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
        }
        return;
    }
    if (username.length > kMaxUsernameLength || username.length < kMinUsernameLength || password.length > kMaxPasswordLength || password.length < kMinPasswordLength) {
        NSError * error = [MMXClient errorWithTitle:@"Invalid Character Count" message:@"There is an invalid length of characters used in the login information provided." code:400];
        if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
        }
        return;
    }
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];

	NSString *protocol = @"http";
	if (self.delegate.configuration.shouldForceTLS) {
		  protocol = @"https";
	}
	NSString *usersURLString = [NSString stringWithFormat:@"%@://%@:%li/mmxmgmt/api/v1/users",protocol, self.delegate.configuration.baseURL.host,(long)self.delegate.configuration.publicAPIPort];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:usersURLString]];
	
	[request setValue:self.delegate.configuration.appID forHTTPHeaderField:@"X-mmx-app-id"];
	[request setValue:self.delegate.configuration.apiKey forHTTPHeaderField:@"X-mmx-api-key"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	request.HTTPMethod = @"POST";
		
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{ @"username": username,
																  @"password": password,
																  @"name": displayName ?: [NSNull null],
																  @"email": email ?: [NSNull null]}
													   options:NSUTF8StringEncoding
														 error:&error];
	
	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
		if (httpResponse.statusCode == 201) {
			if (success) {
				MMXUserProfile * profile = [MMXUserProfile initWithUsername:username displayName:displayName email:email tags:nil];
				success(profile);
			}
		} else if (error) {
			if (failure) {
				failure(error);
			}
		} else if (httpResponse.statusCode == 409) {
			NSError *httpError = [MMXClient errorWithTitle:@"Duplicate entry" message:@"You have tried to create a duplicate entry." code:(int)httpResponse.statusCode];
			if (failure) {
				failure(httpError);
			}
		} else {
			NSError *httpError = [MMXClient errorWithTitle:@"Unknown Error" message:@"Unfortunately an unknown error occurred while trying to create your user." code:(int)httpResponse.statusCode];
			if (failure) {
				failure(httpError);
			}
		}
	}] resume];
}

- (void)registerAnonymousWithSuccess:(void (^)(BOOL success))success
                             failure:(void (^)(NSError * error))failure {
    
    MMXUserProfile * user = [MMXUserProfile initWithUsername:[self.delegate anonymousCredentials].user displayName:[UIDevice currentDevice].name email:@"" tags:nil];
	NSError * iqError;
    XMPPIQ *userIQ = [self registrationIQForUser:user createMode:@"GUEST" password:[self.delegate anonymousCredentials].password error:&iqError];
	if (userIQ) {
		[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Registration Failure."]);
					});
				}
			} else {
				MMXIQResponse *createUserResp = [MMXIQResponse responseFromIQ:iq];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (createUserResp.code == 200 || createUserResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([createUserResp errorFromResponse:@"User Registration Failure"]);
						});
					}
				}
			}
		}];
	} else {
		if (iqError && failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(iqError);
			});
		}
	}
}

- (XMPPIQ*)registrationIQForUser:(MMXUserProfile *)user
					  createMode:(NSString *)createMode
						password:(NSString *)password
						   error:(NSError **)error {
	
	NSDictionary *userDictionary = [user creationRequestDictionaryWithAppID:self.delegate.configuration.appID
																	 APIKey:self.delegate.configuration.apiKey
															anonymousSecret:self.delegate.configuration.anonymousSecret
																 createMode:createMode
																   password:password];
    
    NSError *creationError;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:userDictionary xmlns:MXnsUser commandStringValue:MXcommandCreate error:&creationError];
    if (!creationError) {

        XMPPIQ *userIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
        [userIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        return userIQ;
    }
	*error = creationError;
    return nil;
}

#pragma mark - Current User

- (void)userProfileWithSuccess:(void (^)(MMXUserProfile *))success
					   failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager userProfileWithSuccess"];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	NSError *error;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:@{}
																 xmlns:MXnsUser
													commandStringValue:@"get"
																 error:&error];
	if (!error) {
		XMPPIQ *userIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
		[userIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Request Failure."]);
					});
				}
			} else {
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				MMXUserProfile * user = [MMXUserProfile userFromIQ:iq username:[[[self.delegate currentJID] usernameWithoutAppID] jidUnescapedString]];
				if (user) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(user);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([MMXClient errorWithTitle:@"User Request Failure." message:@"An unknown error occured while trying to fetch your user information." code:500]);
						});
					}
				}
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		}
	}
}

- (void)endpointsForUser:(MMXUserID *)user
				 success:(void (^)(NSArray *))success
				 failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager endpointsForUser. Username = %@", user.username];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if (user == nil || user.username == nil || [user.username isEqualToString:@""]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid user" message:@"You must pass in a vlaid user object to use this API." code:500]);
			});
		}
		return;
	}
	[self.delegate.deviceManager devicesForUser:user success:^(NSArray *devices) {
		if (devices) {
			NSMutableArray * endpoints = @[].mutableCopy;
			for (MMXDeviceProfile * userDevice in devices) {
				[endpoints addObject:userDevice.endpoint];
			}
			if (success) {
				dispatch_async(self.callbackQueue, ^{
					success(endpoints);
				});
			}
		}
	} failure:^(NSError *error) {
		dispatch_async(self.callbackQueue, ^{
			failure(error);
		});
	}];
}

#pragma mark - Get User
//FIXME: This should be refactored and handle edge cases better
- (void)userForUserName:(NSString *)username
				success:(void (^)(MMXUser *))success
				failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager userForUserName. MMXQuery = %@", username];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	NSError *error;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:@{@"userId": username} xmlns:MXnsUser commandStringValue:@"get" error:&error];
	
	XMPPIQ *userIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
	[userIQ addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
	[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		XMPPIQ * iq = (XMPPIQ *)obj;
		if ([iq isErrorIQ]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([iq errorWithTitle:@"Get User Failure."]);
				});
			}
		} else {
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
			NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement];
			MMXUser *user = [MMXUser new];
			if (mmxElement) {
				NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
				NSError* error;
				NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
				NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
				if (jsonDictionary) {
						if (error) {
							if (failure) {
								dispatch_async(self.callbackQueue, ^{
									failure(error);
								});
							}
						} else {
							if (jsonDictionary[@"userId"]) {
								user.username = jsonDictionary[@"userId"];
							}
							if (jsonDictionary[@"displayName"]) {
								user.displayName = jsonDictionary[@"displayName"];
							}
						}
					if (user.username) {
						dispatch_async(self.callbackQueue, ^{
							success(user);
						});
					} else {
						if (failure) {
							NSError * parsingError = [MMXClient errorWithTitle:@"Unknown Error Occurred." message:@"Please try again later." code:500];
							dispatch_async(self.callbackQueue, ^{
								failure(parsingError);
							});
						}
					}
				}
			} else {
				if (failure) {
					NSError * parsingError = [MMXClient errorWithTitle:@"Unknown Error Occurred." message:@"Please try again later." code:500];
					dispatch_async(self.callbackQueue, ^{
						failure(parsingError);
					});
				}
			}
		}
	}];

}

#pragma mark - Update User

- (void)updateEmail:(NSString *)email
			success:(void (^)(BOOL))success
			failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager updateEmail. Email = %@", email];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if (email && ![email isEqualToString:@""]) {
		XMPPIQ *userIQ = [self updateIQForUserDict:@{@"email": email}];
		[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Update Failure."]);
					});
				}
			} else {
				MMXIQResponse *createUserResp = [MMXIQResponse responseFromIQ:iq];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (createUserResp.code == 200 || createUserResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([createUserResp errorFromResponse:@"User Update Failure"]);
						});
					}
				}
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Entry" message:@"The email parameter cannot be nil." code:401]);
			});
		}
	}
}

- (void)updateDisplayName:(NSString *)displayName
				  success:(void (^)(BOOL))success
				  failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager updateDisplayName. DisplayName = %@", displayName];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if (displayName && ![displayName isEqualToString:@""]) {
		XMPPIQ *userIQ = [self updateIQForUserDict:@{@"displayName": displayName}];
		[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
			XMPPIQ * iq = (XMPPIQ *)obj;
			if ([iq isErrorIQ]) {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([iq errorWithTitle:@"User Update Failure."]);
					});
				}
			} else {
				MMXIQResponse *createUserResp = [MMXIQResponse responseFromIQ:iq];
				NSString* iqId = [iq elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				if (createUserResp.code == 200 || createUserResp.code == 201) {
					if (success) {
						dispatch_async(self.callbackQueue, ^{
							success(YES);
						});
					}
				} else {
					if (failure) {
						dispatch_async(self.callbackQueue, ^{
							failure([createUserResp errorFromResponse:@"User Update Failure"]);
						});
					}
				}
			}
		}];
	} else {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Entry" message:@"The displayName parameter cannot be nil." code:401]);
			});
		}
		return;
	}
}

- (void)updateUser:(MMXUserProfile *)user
		   success:(void (^)(BOOL))success
		   failure:(void (^)(NSError *))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager updateUser. User = %@", user];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if (user == nil) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Entry" message:@"The user parameter cannot be nil." code:401]);
			});
		}
		return;
	} else if (![user.userID.username isEqualToString:[[self.delegate currentJID] usernameWithoutAppID]]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Entry" message:@"You can only update the currently logged in user." code:401]);
			});
		}
		return;
	} else if ((user.email == nil || [user.email isEqualToString:@""]) && (user.displayName == nil || [user.displayName isEqualToString:@""])){
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([MMXClient errorWithTitle:@"Invalid Entry" message:@"Either email or displayName must be valid to update." code:401]);
			});
		}
		return;
	}
	XMPPIQ *userIQ = [self updateIQForUser:user];
	[self.delegate sendIQ:userIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		XMPPIQ * iq = (XMPPIQ *)obj;
		if ([iq isErrorIQ]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([iq errorWithTitle:@"User Update Failure."]);
				});
			}
		} else {
			MMXIQResponse *createUserResp = [MMXIQResponse responseFromIQ:iq];
			NSString* iqId = [iq elementID];
			[self.delegate stopTrackingIQWithID:iqId];
			if (createUserResp.code == 200 || createUserResp.code == 201) {
				if (success) {
					dispatch_async(self.callbackQueue, ^{
						success(YES);
					});
				}
			} else {
				if (failure) {
					dispatch_async(self.callbackQueue, ^{
						failure([createUserResp errorFromResponse:@"User Update Failure"]);
					});
				}
			}
		}
	}];
	
}

- (XMPPIQ*)updateIQForUserDict:(NSDictionary *)userDictionary {
	NSError *error;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:userDictionary xmlns:MXnsUser commandStringValue:@"update" error:&error];
	if (!error) {
		
		XMPPIQ *userIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
		[userIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		return userIQ;
	}
	return nil;
}

- (XMPPIQ*)updateIQForUser:(MMXUserProfile *)user {
	
	NSDictionary *userDictionary = @{@"email": user.email ? user.email : [NSNull null],
									 @"displayName": user.displayName ? user.displayName : [NSNull null]};
	
	NSError *error;
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:userDictionary xmlns:MXnsUser commandStringValue:@"update" error:&error];
	if (!error) {
		
		XMPPIQ *userIQ = [[XMPPIQ alloc] initWithType:@"set" child:mmxElement];
		[userIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
		return userIQ;
	}
	return nil;
}


#pragma mark - Query Users

- (void)queryUsers:(MMXQuery *)userQuery
		   success:(void (^)(int totalCount, NSArray * users))success
		   failure:(void (^)(NSError * error))failure {
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager queryUsers. MMXQuery = %@", userQuery];
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	NSError *error;
	NSMutableDictionary *userQueryDict = [userQuery dictionaryRepresentation].mutableCopy;
//	[userQueryDict setObject:@{@"match":@"PREFIX",@"value":@"%"} forKey:@"displayName"];
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:userQueryDict xmlns:MXnsUser commandStringValue:@"search" error:&error];
	
	XMPPIQ *queryIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
	[queryIQ addAttributeWithName:@"id" stringValue:[[NSUUID UUID] UUIDString]];
	[self.delegate sendIQ:queryIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		XMPPIQ * returnIQ = (XMPPIQ *)obj;
		if ([returnIQ isErrorIQ] && failure) {
			NSError * error = [MMXUserQueryResponse responseWithError:[returnIQ errorWithTitle:@"User Query Error"]].error;
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		} else {
			if (success) {
				MMXUserQueryResponse *response = [MMXUserQueryResponse responseFromIQ:returnIQ];
				NSString* iqId = [returnIQ elementID];
				[self.delegate stopTrackingIQWithID:iqId];
				dispatch_async(self.callbackQueue, ^{
					success(response.totalCount, response.users);
				});
			}
		}
	}];
}

#pragma mark - Users Tags

- (void)tagsWithSuccess:(void (^)(NSArray * tags))success
				failure:(void (^)(NSError * error))failure {
    NSError *creationError;
    NSXMLElement *mmxElement = [[NSXMLElement alloc] initWithName:MXmmxElement xmlns:MXnsUser];
    [mmxElement addAttributeWithName:MXcommandString stringValue:MXcommandGetTags];
    [mmxElement addAttributeWithName:MXctype stringValue:MXctypeJSON];
    if (!creationError) {
        XMPPIQ *tagsIQ = [[XMPPIQ alloc] initWithType:@"get" child:mmxElement];
        [tagsIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
        [tagsIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
        [self.delegate sendIQ:tagsIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
            XMPPIQ * iq = (XMPPIQ *)obj;
            if ([iq isErrorIQ]) {
                if (failure) {
                    failure([iq errorWithTitle:@"User Tags Request Failure."]);
                }
            } else {
                NSXMLElement* mmxElement =  [iq elementForName:MXmmxElement xmlns:MXnsUser];
                if (mmxElement && success) {
					NSArray * tagArray;
                    NSString* jsonContent =  [[mmxElement childAtIndex:0] XMLString];
                    NSError* error;
                    NSData* jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
					if (error) {
						if (failure) {
							failure(error);
						}
					} else {
						if (jsonDictionary[@"tags"] && jsonDictionary[@"tags"] != [NSNull null]) {
							tagArray = jsonDictionary[@"tags"];
						} else {
							tagArray = @[];
						}
					}
					dispatch_async(self.callbackQueue, ^{
						success(tagArray);
					});
                }
                NSString* iqId = [iq elementID];
                [self.delegate stopTrackingIQWithID:iqId];
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

- (void)addTags:(NSArray *)tags
					  success:(void (^)(BOOL))success
					  failure:(void (^)(NSError *))failure {
	[self updateTagsForCurrentUser:tags updateType:@"add" success:success failure:failure];
}

- (void)setTags:(NSArray *)tags
					  success:(void (^)(BOOL))success
					  failure:(void (^)(NSError *))failure {
	[self updateTagsForCurrentUser:tags updateType:@"set" success:success failure:failure];
}

- (void)removeTags:(NSArray *)tags
						success:(void (^)(BOOL))success
						failure:(void (^)(NSError *))failure {
	[self updateTagsForCurrentUser:tags updateType:@"remove" success:success failure:failure];
}

- (void)updateTagsForCurrentUser:(NSArray *)tags
					  updateType:(NSString *)updateType
						 success:(void (^)(BOOL))success
						 failure:(void (^)(NSError *))failure {
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if ([updateType isEqualToString:@"add"] && (tags == nil || tags.count < 1)) {
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
					failure([MMXClient errorWithTitle:@"Invalid Tags" message:@"Tag was either too long or used invalid characters." code:500]);
				});
			}
			return;
		}
	}
	[[MMXLogger sharedLogger] verbose:@"MMXAccountManager %@TagsForCurrentUser. Tags = %@",updateType, tags];
    NSError * parsingError;
	NSDictionary * dict = @{@"tags":tags ? tags : @[]};
	NSString *commandString = [NSString stringWithFormat:@"%@Tags",updateType];
	NSXMLElement *mmxElement = [MMXUtils mmxElementFromValidJSONObject:dict xmlns:MXnsUser commandStringValue:commandString error:&parsingError];
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
						failure([iq errorWithTitle:[NSString stringWithFormat:@"%@ User Tags Failure.",[updateType capitalizedString]]]);
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
							failure([setTagsResp errorFromResponse:[NSString stringWithFormat:@"%@ User Tags Failure.",[updateType capitalizedString]]]);
						});
                    }
                }
            }
        }];
    }
}

- (void)updatePassword:(NSString *)password
			   success:(void (^)(BOOL))success
			   failure:(void (^)(NSError *))failure {
	if (![self hasActiveConnection]) {
		if (failure) {
			dispatch_async(self.callbackQueue, ^{
				failure([self connectionStatusError]);
			});
		}
		return;
	}
	if (password.length > kMaxPasswordLength || password.length < kMinPasswordLength) {
		if (failure) {
			NSError * error = [MMXClient errorWithTitle:@"Invalid Character Count" message:@"There is an invalid length of characters used in the password provided." code:400];
			dispatch_async(self.callbackQueue, ^{
				failure(error);
			});
		}
		return;
	}
	 NSString *toStr = [self.delegate currentJID].domain;
	 NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
	 
	 NSXMLElement *usernameElement = [NSXMLElement elementWithName:@"username"
												stringValue:[self.delegate currentJID].user];
	 NSXMLElement *passwordElement = [NSXMLElement elementWithName:@"password"
												stringValue:password];
	 [query addChild:usernameElement];
	 [query addChild:passwordElement];
	 
	 XMPPIQ *passwordIQ = [XMPPIQ iqWithType:@"set"
						  to:[XMPPJID jidWithString:toStr]
				   elementID:[self.delegate generateMessageID]
					   child:query];
	[passwordIQ addAttributeWithName:@"from" stringValue: [[self.delegate currentJID] full]];
	[passwordIQ addAttributeWithName:@"id" stringValue:[self.delegate generateMessageID]];
	[self.delegate sendIQ:passwordIQ completion:^ (id obj, id <XMPPTrackingInfo> info) {
		XMPPIQ * iq = (XMPPIQ *)obj;
		if ([iq isErrorIQ]) {
			if (failure) {
				dispatch_async(self.callbackQueue, ^{
					failure([iq errorWithTitle:@"Change Password Failure."]);
				});
			}
		} else {
			if (success) {
				dispatch_async(self.callbackQueue, ^{
					success(YES);
				});
			}
		}
	}];
}

#pragma mark - Helper Methods

- (BOOL)hasActiveConnection {
	if (self.delegate.connectionStatus != MMXConnectionStatusAuthenticated &&
		self.delegate.connectionStatus != MMXConnectionStatusConnected) {
		return NO;
	}
	return YES;
}

- (NSError *)connectionStatusError {
	return [MMXClient errorWithTitle:@"Not currently connected." message:@"The feature you are trying to use requires an active connection." code:503];
}

#pragma mark - NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {

    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (self.delegate.configuration.shouldForceTLS && self.delegate.configuration.allowInvalidCertificates) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end
