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

import AFNetworking
import MagnetMax
import UIKit

class SignInViewController : BaseViewController {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var txtfEmail : UITextField!
    @IBOutlet weak var txtfPassword : UITextField!
    @IBOutlet weak var btnRemember : UISwitch!
    @IBOutlet weak var chbRememberMe: UIImageView!
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resignOnBackgroundTouch()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        txtfPassword.text = ""
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    //MARK: Actions
    
    
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
                    if MMXHttpError(rawValue: error.code) == .ServerTimeout || MMXHttpError(rawValue: error.code) == .Offline {
                        self.showAlert(kStr_NoInternetError, title: kStr_NoInternetErrorTitle, closeTitle: kStr_Close)
                    } else {
                        self.showAlert(kStr_EmailPassNotFound, title: kStr_CouldntLogin, closeTitle: kStr_Close)
                    }
            })
        } else {
            showAlert(kStr_FillEmailPass, title: kStr_FillEmailPass, closeTitle: kStr_Close)
        }
    }
    
    
    //MARK: - private Methods
    
    
    private func validateCredential() -> (String, String)? {
        
        guard let email = txtfEmail.text where (email.isEmpty == false) else {
            return nil
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false) else {
            return nil
        }
        
        return (email, password)
    }
}
