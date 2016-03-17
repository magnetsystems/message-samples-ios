//
//  AuthManager.m
//  M.A.C.
//
//  Created by Vladimir Yevdokimov on 5/15/15.
//  Copyright (c) 2015 magnet. All rights reserved.
//

#import "AuthManager.h"

@implementation AuthManager

+ (instancetype)shared
{
    static AuthManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [AuthManager new];
    });
    return shared;
}
-(void)loginUserWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)remember callback:(AuthCallback)result
{
    if ([MMUser currentUser]) {
        result?result(YES,nil):nil;
        return;
    }
    
    NSURLCredential *creds = [NSURLCredential credentialWithUser:email password:password persistence:NSURLCredentialPersistenceNone];
    [MMUser login:creds rememberMe:remember success:^{
        result?result(YES,nil):nil;
    } failure:^(NSError * error) {
        result?result(NO,error):nil;
    }];
}

- (void)loginUserWithEmail:(NSString*)email password:(NSString*)password callback:(AuthCallback)result
{
    [self loginUserWithEmail:email password:password rememberMe:NO callback:result];
    
}

- (void)logout
{
    [MMUser logout:^{
        [MMX stop];
    } failure:^(NSError * err) {
    }];
}

@end
