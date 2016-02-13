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
    @IBOutlet weak var chbRememberMe: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resignOnBackgroundTouch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        txtfPassword.text = ""
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func selectCheckbox(sender: UIButton) {
        if btnRemember.on {
            btnRemember.on = false;
            chbRememberMe.image = UIImage(named: "check_off");
        } else {
            btnRemember.on = true;
            chbRememberMe.image = UIImage(named: "check_on");
        }
    }
    
    @IBAction func signInAction() {
        
        // Validate
        if let (email, password) = validateCredential() {
            
            // Login
            self.showLoadingIndicator()
            let credential = NSURLCredential(user: email, password: password, persistence: .None)
            MMUser.login(credential, rememberMe: btnRemember.on, success: {
                self.hideLoadingIndicator()
                self.performSegueWithIdentifier(kSegueShowSlideMenu, sender: nil)
                }, failure: { error in
                    print("[ERROR]: \(error)")
                    self.hideLoadingIndicator()
                    self.showAlert(kStr_EmailPassNotFound, title: kStr_CouldntLogin, closeTitle: kStr_Close)
            })
        } else {
            showAlert(kStr_FillEmailPass, title: kStr_FillEmailPass, closeTitle: kStr_Close)
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
    
    deinit {
    }
}
