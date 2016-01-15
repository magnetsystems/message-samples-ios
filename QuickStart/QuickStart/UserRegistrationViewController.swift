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

class UserRegistrationViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
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
    
    
    @IBAction func register() {
        do {
            // Validate
            let (userName, password) = try validateCredential()
            
            // Register
            let user = MMUser()
            user.userName = userName
            user.password = password
            
            user.register({ [weak self] user in
                print("[INFO]: User created successfully!")

                let userCreatedAlert = UIAlertController(title: "User created successfully", message:"Credential: \(userName)/\(password)", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                userCreatedAlert.addAction(defaultAction)
                
                self?.presentViewController(userCreatedAlert, animated: true, completion: nil)

            }, failure: { error in
                if error.code == 409 {
                    print("[ERROR]: User already exists!")
                } else {
                    print("[ERROR]: \(error)")
                }
            })
        } catch {
            print("[ERROR]: Could not register because of invalid userName or password")
        }
    }
}

