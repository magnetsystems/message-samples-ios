//
//  SignInViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class SignInViewController : BaseViewController {
    
    @IBOutlet weak var txtfEmail : UITextField!
    @IBOutlet weak var txtfPassword : UITextField!
    @IBOutlet weak var btnRemember : UISwitch!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        txtfPassword.text = ""
    }
    
    @IBAction func signInAction() {
        
//        self.performSegueWithIdentifier("showSlideMenuVC", sender: nil)

        // Validate
        if let (email, password) = validateCredential() {
        
            // Login
            self.showLoadingIndicator()
            let credential = NSURLCredential(user: email, password: password, persistence: .None)
            MMUser.login(credential, rememberMe: btnRemember.on, success: {
                // Initialize Magnet Message
                MagnetMax.initModule(MMX.sharedInstance(), success: { [weak self] in
                    self?.hideLoadingIndicator()
                    self?.performSegueWithIdentifier("showSlideMenuVC", sender: nil)
                }, failure: { error in
                    self.hideLoadingIndicator()
                    print("[ERROR]: \(error)")
                })
            }, failure: { error in
                print("[ERROR]: \(error)")
                self.hideLoadingIndicator()
                self.showAlert(error.localizedDescription, title: error.localizedFailureReason ?? "", closeTitle: "Close")
            })
        } else {
            showAlert("Email or password is incorrect", title: "Please check your information and try again", closeTitle: "Close")
        }
    }

    private func validateCredential() -> (String, String)? {
        
        guard let email = txtfEmail.text where (email.isEmpty == false) else {
            return nil
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false) else {
            return nil
        }
        
        return (email, password)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
