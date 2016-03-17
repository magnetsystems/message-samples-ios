//
//  AuthManager.h
//  M.A.C.
//
//  Created by Vladimir Yevdokimov on 5/15/15.
//  Copyright (c) 2015 magnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MagnetMax;

typedef void(^AuthCallback)(BOOL success, NSError *error);

@interface AuthManager : NSObject


+ (instancetype)shared;

- (void)loginUserWithEmail:(NSString*)email password:(NSString*)password callback:(AuthCallback)result; // no remember me
- (void)loginUserWithEmail:(NSString*)email password:(NSString*)password rememberMe:(BOOL)remember callback:(AuthCallback)result;
- (void)logout;

@end
