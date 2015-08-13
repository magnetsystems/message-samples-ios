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

#import "MMXUser.h"
#import "MagnetDelegate.h"
#import "MMX.h"

@implementation MMXUser

+ (MMXUser *)currentUser {
	return [MagnetDelegate sharedDelegate].currentUser;
}
- (void)registerWithCredentials:(NSURLCredential *)credential
						success:(void (^)(void))success
						failure:(void (^)(NSError *))failure {
	[[MMXClient sharedClient].accountManager createAccountForUsername:credential.user
														  displayName:self.displayName
																email:self.email password:credential.password
															  success:^(MMXUserProfile *userProfile) {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (void)logInWithCredentials:(NSURLCredential *)credential
					 success:(void (^)(MMXUser *))success
					 failure:(void (^)(NSError *))failure {
	[[MagnetDelegate sharedDelegate] logInWithCredential:credential
												 success:^(MMXUser *user) {
		if (success) {
			success(user);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (void)logOutWithSuccess:(void (^)(void))success
				  failure:(void (^)(NSError *))failure {
	if ([MMXClient sharedClient].connectionStatus != MMXConnectionStatusAuthenticated) {
		if (success) {
			success();
		}
	} else {
		[[MagnetDelegate sharedDelegate] logOutWithSuccess:^{
			if (success) {
				success();
			}
		} failure:^(NSError *error) {
			if (failure) {
				failure(error);
			}
		}];
	}
}

- (void)changePasswordWithCredentials:(NSURLCredential *)credential
							  success:(void (^)(void))success
							  failure:(void (^)(NSError *))failure {
	//FIXME: This is not correct. Must be logged in, etc. Think through the cases.
	[[MMXClient sharedClient].accountManager updatePassword:credential.password success:^(BOOL successful) {
		if (success) {
			success();
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (void)findByName:(NSString *)name
			 limit:(int)limit
		   success:(void (^)(int, NSArray *))success
		   failure:(void (^)(NSError *))failure {
	MMXQuery *query = [MMXQuery queryForUserDisplayNameStartsWith:name
															 tags:nil
															limit:limit];
	[[MMXClient sharedClient].accountManager queryUsers:query
												success:^(int totalCount, NSArray *users) {
		NSMutableArray *userArray = [[NSMutableArray alloc] initWithCapacity:users.count];
		for (MMXUserProfile *profile in users) {
			[userArray addObject:[MMXUser userFromMMXUserProfile:profile]];
		}
		if (success) {
			success(totalCount, userArray.copy);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];
}

+ (void)findByTags:(NSSet *)tags
			 limit:(int)limit
		   success:(void (^)(int, NSArray *))success
		   failure:(void (^)(NSError *))failure {
	MMXQuery *query = [MMXQuery queryForUserDisplayNameStartsWith:@"" tags:[tags allObjects] limit:limit];
	[[MMXClient sharedClient].accountManager queryUsers:query success:^(int totalCount, NSArray *users) {
		NSMutableArray *userArray = [[NSMutableArray alloc] initWithCapacity:users.count];
		for (MMXUserProfile *profile in users) {
			[userArray addObject:[MMXUser userFromMMXUserProfile:profile]];
		}
		if (success) {
			success(totalCount, userArray.copy);
		}
	} failure:^(NSError *error) {
		if (failure) {
			failure(error);
		}
	}];

}

+ (MMXUser *)userFromMMXUserProfile:(MMXUserProfile *)profile {
	MMXUser *user = [MMXUser new];
	user.username = profile.userID.username;
	user.displayName = profile.displayName;
	user.email = profile.email;
	return user;
}

- (void)addDeviceToken:(NSData *)token {
	if ([MMXClient sharedClient].connectionStatus == MMXConnectionStatusConnected ||
		([MMXClient sharedClient].connectionStatus == MMXConnectionStatusAuthenticated &&
		 [[MMXUser currentUser].username isEqualToString:self.username])) {
		[[MMXClient sharedClient] updateRemoteNotificationDeviceToken:token];
	}	
}

@end
