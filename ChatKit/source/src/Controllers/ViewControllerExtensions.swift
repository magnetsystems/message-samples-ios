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

import UIKit

class AcceptAnyTouchDelegate : NSObject, UIGestureRecognizerDelegate {
    static let sharedDelegate = AcceptAnyTouchDelegate()
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let _ = touch.view as? UITextField {
            return false
        } else if let _ = touch.view as? UITextView {
            return false
        }
        return true
    }
}

extension UIViewController  {
    
    
    //MARK: - public Methods
    
    
    public func resignOnBackgroundTouch() -> Void {
        let onTouch = UILongPressGestureRecognizer.init(target: self, action: "didTouch:")
        onTouch.delegate = AcceptAnyTouchDelegate.sharedDelegate
        onTouch.minimumPressDuration = 0.0
        onTouch.cancelsTouchesInView = false
        self.view.addGestureRecognizer(onTouch)
    }
    
    public func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = Popup(message: message, title: title, closeTitle: closeTitle, handler: handler)
        alert.presentForController(self)
    }
    
    
    //MARK: - private Methods
    
    
    @objc private func didTouch(tap : UILongPressGestureRecognizer) {
        resignFirstResponder(self.view)
    }
    
    private func resignFirstResponder(view : UIView) -> Bool {
        if view.isFirstResponder() {
            view.resignFirstResponder()
            
            if let searchBar = view as? UISearchBar {
                searchBar.setShowsCancelButton(false, animated: true)
            }
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