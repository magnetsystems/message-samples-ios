//
//  RegisterViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class RegisterViewController : BaseViewController {
    
    @IBOutlet weak var txtfFirstName : UITextField!
    @IBOutlet weak var txtfLastName : UITextField!
    @IBOutlet weak var txtfEmail : UITextField!
    @IBOutlet weak var txtfPassword : UITextField!
    @IBOutlet weak var txtfPasswordAgain : UITextField!
    
    
    var viewOffset: CGFloat!
    var keyboardIsShowing = false
    
    override func viewDidLoad() {
         super.viewDidLoad()
        self.resignOnBackgroundTouch()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: Handlers
    
    @IBAction func registerAction() {
        do {
            // Validate
            let (firstName, lastName, email, password) = try validateCredential()
            
            // Register
            let user = MMUser()
            user.userName = email
            user.firstName = trimWhiteSpace(firstName)
            user.lastName = trimWhiteSpace(lastName)
            user.password = password
            user.email = trimWhiteSpace(email)
            
            // Login
            let credential = NSURLCredential(user: email, password: password, persistence: .None)
            
            self.showLoadingIndicator()
            
            user.register({ [weak self] user in
                self?.login(credential)
                }, failure: { [weak self] error in
                    if error.code == 409 {
                        // The user already exists, let's attempt a login
                        self?.login(credential)
                    } else {
                        print("[ERROR]: \(error)")
                        self?.hideLoadingIndicator()
                        self?.showAlert(error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: kStr_Close)
                    }
                })
        } catch InputError.InvalidUserNames {
            self.showAlert(kStr_EnterFirstLastName, title: kStr_FieldRequired, closeTitle: kStr_Close)
        } catch InputError.InvalidEmail {
            self.showAlert(kStr_EnterEmail, title: kStr_FieldRequired, closeTitle: kStr_Close)
        } catch InputError.InvalidPassword {
            self.showAlert(kStr_EnterPasswordAndVerify, title: kStr_PasssNotMatch, closeTitle: kStr_Close)
        } catch InputError.InvalidPasswordLength {
            self.showAlert(kStr_EnterPasswordLength, title: kStr_PasswordShort, closeTitle: kStr_Close)
        } catch { }
    }
    
    // MARK: Private implementation
    
    private func trimWhiteSpace(string : String) -> String {
      return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private enum InputError: ErrorType {
        case InvalidUserNames
        case InvalidEmail
        case InvalidPassword
        case InvalidPasswordLength
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func validateCredential() throws -> (String, String, String, String) {
        // Get values from UI
        guard let firstName = txtfFirstName.text where (trimWhiteSpace(firstName).characters.count >= kMinNameLength),
            let lastName = txtfLastName.text where (trimWhiteSpace(lastName).characters.count >= kMinNameLength) else {
                throw InputError.InvalidUserNames
        }
        
        guard let email = txtfEmail.text where (email.isEmpty == false) && isValidEmail(trimWhiteSpace(email)) else {
            throw InputError.InvalidEmail
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false),
            let passwordAgain = txtfPasswordAgain.text where (passwordAgain.isEmpty == false && password == passwordAgain) else {
                throw InputError.InvalidPassword
        }
        
        if password.characters.count < kMinPasswordLength { throw InputError.InvalidPasswordLength }
        
        return (firstName, lastName, email, password)
    }
    
    //MARK: Helpers
    
    func login(credential: NSURLCredential) {
        
        MMUser.login(credential, rememberMe: true, success: { [weak self] in
            // Initialize Magnet Message
            MagnetMax.initModule(MMX.sharedInstance(), success: {
                self?.hideLoadingIndicator()
                self?.performSegueWithIdentifier(kSegueRegisterToHome, sender: nil)
                }, failure: { error in
                    self?.hideLoadingIndicator()
                    print("[ERROR]: \(error)")
            })
            }, failure: { [weak self] error  in
                self?.hideLoadingIndicator()
                print("[ERROR]: \(error.localizedDescription)")
                self?.showAlert(error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: kStr_Close)
            })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueRegisterToHome {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kUserDefaultsShowProfile)
        }
    }
}
