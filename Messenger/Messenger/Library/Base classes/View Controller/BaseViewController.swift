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

extension UIViewController {
    
    
    //MARK: - public Methods
    
    
    public func resignOnBackgroundTouch () -> Void {
        let onTouch = UITapGestureRecognizer.init(target: self, action: "didTouch:")
        self.view.addGestureRecognizer(onTouch)
    }
    
    @objc private func didTouch(tap : UITapGestureRecognizer) {
        resignFirstResponder(self.view)
    }
    
    
    //MARK: - private Methods
    
    
    private func resignFirstResponder(view : UIView) -> Bool {
        if (view.isFirstResponder()) {
            view.resignFirstResponder()
            
            return true;
        }
        
        for sub in view.subviews {
            if resignFirstResponder(sub) {
                
                return true;
            }
        }
        
        return false
    }
}

class BaseViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - public Methods
    
    
    func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = Popup(message: message, title: title, closeTitle: closeTitle, handler: handler)
        alert.presentForController(self)
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
