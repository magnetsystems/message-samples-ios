//
//  ViewController.swift
//  ChatKit
//
//  Created by Lorenzo Stanton on 2/10/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import UIKit
import ChatKitUI
import MagnetMax

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = MMUser.init()
        user.password = "gogo"
        user.userName = "jgo"
        user.register({ user in
            self.login(user)
            }, failure: { error in
                if error.code == 409 {
                    self.login(user)
                    return
                }
                print("[ERROR] \(error.localizedDescription)")
        })
    }
    func login (user : MMUser) {
        let cred = NSURLCredential.init(user: user.userName, password: user.password, persistence: .None)
        MMUser.login(cred, rememberMe: false, success: {
//            let url = NSURL.init(string: "https://clipartion.com/wp-content/uploads/2015/11/free-clipart-of-happy-person.png")
//            MMUser.currentUser()?.setAvatarWithURL(url!, success: { url in
                let c = ContactsPickerController(disabledUsers: [MMUser.currentUser()!])
                self.presentViewController(c, animated: true, completion: nil)
//                }, failure: {error in
//                   print("[ERROR] \(error.localizedDescription)")
//            })
            }, failure: { error in
                print("[ERROR] \(error.localizedDescription)")
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

