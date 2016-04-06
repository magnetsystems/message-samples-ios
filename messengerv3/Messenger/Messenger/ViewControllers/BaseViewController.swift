/*
 * Copyright (c) 2016 Magnet Systems, Inc.
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


import ChatKit
import UIKit

class BaseViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - public Methods
    
    
    override func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let button = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(button)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    func hideLoadingIndicator() {
        activityIndicator?.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator?.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    
    //MARK: UITextField delegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
