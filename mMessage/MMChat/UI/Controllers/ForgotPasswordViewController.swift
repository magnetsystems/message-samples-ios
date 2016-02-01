//
//  ForgotPasswordViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 12/23/15.
//  Copyright © 2015 Kostya Grishchenko. All rights reserved.
//

import UIKit

class ForgotPasswordViewController : BaseViewController {

    @IBOutlet weak var txtfEmail : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func submitAction() {
        
    }
    
    @IBAction func returnToSignInAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
