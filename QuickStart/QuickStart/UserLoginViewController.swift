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

class UserLoginViewController: UIViewController {
    
    
    // MARK: Outlets
    
   
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loggedInMessageLabel: UILabel!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    // MARK: Private implementation
    
    
    private enum CurrentMode {
        case LoggedIn
        case LoggedOut
    }
    
    private var currentMode: CurrentMode = .LoggedIn {
        didSet {
            switch currentMode {
            case .LoggedIn:
                guard let currentUser = MMUser.currentUser() else {
                    return
                }
                userNameTextField.hidden = true
                passwordTextField.hidden = true
                logInButton.hidden = true
                logOutButton.enabled = true
                loggedInMessageLabel.text = "You are logged in as \(currentUser.userName)"
                loggedInMessageLabel.hidden = false
            case .LoggedOut:
                userNameTextField.hidden = false
                passwordTextField.hidden = false
                logInButton.hidden = false
                logOutButton.enabled = false
                loggedInMessageLabel.text = ""
                loggedInMessageLabel.hidden = true
            }
        }
    }
    
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
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMode = .LoggedIn
    }
    
    
    // MARK: Actions
    
    
    @IBAction func login() {
        // Log Out first
        MMUser.logout({
            do {
                // Validate
                let (userName, password) = try self.validateCredential()
                
                // Login
                let credential = NSURLCredential(user: userName, password: password, persistence: .None)
                
                MMUser.login(credential,
                    success: {
                                self.currentMode = .LoggedIn
                                
                                let userLoggedInAlert = UIAlertController(title: "User logged in successfully", message:"Credential: \(userName)/\(password)", preferredStyle: .Alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                userLoggedInAlert.addAction(defaultAction)
                                
                                self.presentViewController(userLoggedInAlert, animated: true, completion: nil)
                    }, failure: { error in
                        print("[ERROR]: \(error.localizedDescription)")
                })
            } catch {
                print("[ERROR]: Could not login because of invalid userName or password")
            }
        }, failure: { error in
            print("[ERROR]: \(error.localizedDescription)")
        })
    }

    @IBAction func logout(sender: UIBarButtonItem) {
        MMUser.logout({ [weak self] in
            self?.currentMode = .LoggedOut
        }, failure: { error in
            print("[ERROR]: \(error.localizedDescription)")
        })
    }
}
