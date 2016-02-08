//
//  BaseViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit

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
        activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    //MARK: UITextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
