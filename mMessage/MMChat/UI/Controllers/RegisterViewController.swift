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
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Handlers
    
    @IBAction func registerAction() {
        do {
            // Validate
            let (firstName, lastName, email, password) = try validateCredential()
            
            // Register
            let user = MMUser()
            user.userName = email
            user.firstName = firstName
            user.lastName = lastName
            user.password = password
            user.email = email
            
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
                        self?.showAlert(error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close")
                    }
                })
        } catch InputError.InvalidUserNames {
            self.showAlert("Please enter your first and last name", title: "Field required", closeTitle: "Close")
        } catch InputError.InvalidEmail {
            self.showAlert("Please enter your email", title: "Field required", closeTitle: "Close")
        } catch InputError.InvalidPassword {
            self.showAlert("Please enter your password and verify your password again", title: "Passwords do not match", closeTitle: "Close")
        } catch { }
    }
    
    // MARK: Private implementation
    
    private enum InputError: ErrorType {
        case InvalidUserNames
        case InvalidEmail
        case InvalidPassword
    }
    
    private func validateCredential() throws -> (String, String, String, String) {
        // Get values from UI
        guard let firstName = txtfFirstName.text where (firstName.isEmpty == false),
            let lastName = txtfLastName.text where (lastName.isEmpty == false) else {
                throw InputError.InvalidUserNames
        }
        
        guard let email = txtfEmail.text where (email.isEmpty == false) else {
            throw InputError.InvalidEmail
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false),
            let passwordAgain = txtfPasswordAgain.text where (passwordAgain.isEmpty == false && password == passwordAgain) else {
                throw InputError.InvalidPassword
        }
        
        return (firstName, lastName, email, password)
    }
    
    //MARK: Helpers
    
    func login(credential: NSURLCredential) {
        
        MMUser.login(credential, success: { [weak self] in
            // Initialize Magnet Message
            MagnetMax.initModule(MMX.sharedInstance(), success: {
                self?.hideLoadingIndicator()
                self?.performSegueWithIdentifier("registerToMenuSegue", sender: nil)
                }, failure: { error in
                    self?.hideLoadingIndicator()
                    print("[ERROR]: \(error)")
            })
            }, failure: { [weak self] error  in
                self?.hideLoadingIndicator()
                print("[ERROR]: \(error.localizedDescription)")
                self?.showAlert(error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close")
            })
    }
}
