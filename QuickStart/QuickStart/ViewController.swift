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

import UIKit
import MagnetMax

class ViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    // MARK: Overrides
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MMUser.logout({ () -> Void in
            self.userNameTextField.text = nil
            self.passwordTextField.text = nil
            }) { (error) -> Void in
                print("[ERROR]: \(error)")
        }
    }
    
    
    // MARK: Private implementation
    
    
    private enum InputError: ErrorType {
        case InvalidUserName
        case InvalidPassword
    }
    
    private func validateCredential() throws -> (String, String) {
        // Get values from UI
        guard let userName = userNameTextField.text where (userName.isEmpty == false) else {
            throw InputError.InvalidUserName
        }
        
        guard let password = passwordTextField.text where (password.isEmpty == false) else {
            throw InputError.InvalidPassword
        }
        
        return (userName, password)
    }
    
    
    // MARK: Actions
    
    
    @IBAction func login() {
        do {
            // Validate
            let (userName, password) = try validateCredential()
            
            // Login
            let credential = NSURLCredential(user: userName, password: password, persistence: .None)
            
            MMUser.login(credential,
                success: {
                    print(MMUser.currentUser())
                    self.performSegueWithIdentifier("featuresSegue", sender: nil)
                },
                failure: { error in
                    print("[ERROR]: \(error.localizedDescription)")
            })
        } catch {
            print("[ERROR]: Could not login because of invalid userName or password")
        }
    }
    
    @IBAction func redirectToLoginScreenSegue(segue: UIStoryboardSegue) {
        print("[INFO]: User was logged out, redirected from Features screen")
    }
    
    @IBAction func register() {
        do {
            // Validate
            let (userName, password) = try validateCredential()
            
            // Register
            let user = MMUser()
            user.userName = userName
            user.firstName = userName
            user.password = password
            
            user.register({ [weak self] user in
                self?.login()
                }, failure: { [weak self] error in
                    if error.code == 409 {
                        // The user already exists, let's attempt a login
                        self?.login()
                    }
                    print("[ERROR]: \(error)")
                })
        } catch {
            print("[ERROR]: Could not register because of invalid userName or password")
        }
    }
    
}

