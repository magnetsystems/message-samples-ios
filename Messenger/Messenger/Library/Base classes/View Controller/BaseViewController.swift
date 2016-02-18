//
//  BaseViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func resignOnBackgroundTouch () -> Void {
        let onTouch = UITapGestureRecognizer.init(target: self, action: "didTouch:")
        self.view.addGestureRecognizer(onTouch)
    }
    
    @objc private func didTouch(tap : UITapGestureRecognizer) {
        resignFirstResponder(self.view)
    }
    
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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = Popup(message: message, title: title, closeTitle: closeTitle, handler: handler)
        alert.presentForController(self)
    }
    
    func showLoadingIndicator() {
        activityIndicator?.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator?.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    //MARK: UITextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
