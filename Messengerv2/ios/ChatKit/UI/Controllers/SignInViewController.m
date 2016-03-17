//
//  SignInViewController.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/15/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoIV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoToTopLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthLC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightLC;

@property (weak, nonatomic) IBOutlet UITextField *loginTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIView *rememberCheckboxContent;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxIV;

@end

@implementation SignInViewController

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([SignInViewController class]) bundle:nil];
}

- (void)setupUI
{
    self.loginPlaceholder = @"login/email";
    self.passwordPlaceholder = @"password";
    self.logoIV.image = [UIImage imageNamed:@"logo_magnet"];
    self.rememberMe = YES;
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Customosation

- (void)setLoginPlaceholder:(NSString *)loginPlaceholder
{
    _loginPlaceholder = loginPlaceholder;
    _loginTF.placeholder = _loginPlaceholder;
}


- (void)setPasswordPlaceholder:(NSString *)passwordPlaceholder
{
    _passwordPlaceholder = passwordPlaceholder;
    _passwordTF.placeholder = _passwordPlaceholder;
}

- (void)setHideRememberMeCheckbox:(BOOL)hideRememberMeCheckbox
{
    _hideRememberMeCheckbox = hideRememberMeCheckbox;
    _rememberCheckboxContent.hidden = _hideRememberMeCheckbox;
}

- (void)setLogoImage:(UIImage *)logoImage
{
    _logoImage = logoImage;
    _logoIV.image = _logoImage;
}

- (void)shouldSubmitCredentials:(NSString *)login password:(NSString *)password
{
    NSLog(@"did tap shouldSubmit");
}

#pragma mark - Data operation

- (void)setRememberMe:(BOOL)rememberMe
{
    _rememberMe = rememberMe;
    
    if (_rememberMe) {
        _checkboxIV.image = [UIImage imageNamed:@"chb_select"];
    } else {
        _checkboxIV.image = [UIImage imageNamed:@"chb_deselect"];
    }
}

#pragma mark - Actions

- (IBAction)submit:(UIButton*)sender
{
    [self shouldSubmitCredentials:self.loginTF.text password:self.passwordTF.text];
}

- (IBAction)checkboxTap:(UIButton*)sender
{
    self.rememberMe = !_rememberMe;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_loginTF]) {
        if (_loginTF.text.length == 0) {
            return NO;
        } else {
            [_passwordTF becomeFirstResponder];
        }
    } else if ([textField isEqual:_passwordTF]){
        if (_passwordTF.text.length < _minimupPasswordLength) {
            return NO;
        } else {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

@end