//
//  ChangePasswordViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/4/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import MagnetMax

class ChangePasswordViewController: BaseViewController {
    
    @IBOutlet weak var txtfNewPassword : UITextField!
    @IBOutlet weak var txtfNewPasswordAgain : UITextField!
    
    @IBAction func cancelAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitAction() {
        
        guard let user = MMUser.currentUser(),
            let newPassword = txtfNewPassword.text where (newPassword.isEmpty == false),
            let newPasswordAgain = txtfNewPasswordAgain.text where (newPasswordAgain.isEmpty == false && newPassword == newPasswordAgain)
            else {
                if txtfNewPassword.text !=  txtfNewPasswordAgain.text {
                    showAlert("Password do not match.", title: "Passwords do not match", closeTitle: "Try again")
                } else {
                    showAlert("Password too short.", title: "Password too short", closeTitle: "Try again")
                }
                return
        }
        
        let updateRequest = MMUpdateProfileRequest()
        updateRequest.firstName = user.firstName
        updateRequest.lastName = user.lastName
        updateRequest.email = user.email
        updateRequest.tags = user.tags
        updateRequest.extras = user.extras
        updateRequest.password = newPassword
        
        self.showLoadingIndicator()
        
        MMUser.updateProfile(updateRequest, success: { [weak self] user in
            self?.hideLoadingIndicator()
            self?.showAlert("Your password has been successfully changed", title: "Password Reset", closeTitle: "Continue", handler: { (_) -> Void in
                self?.cancelAction()
            })
            }) { [weak self] error in
                self?.hideLoadingIndicator()
                self?.showAlert("Couldn't change password please try again", title: "Could't Change", closeTitle: "Try again")
        }
    }
}
