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
    var currentController : UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //UserGenerator.generateUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = MMUser.init()
        user.password = "gogogo"
        user.userName = "usesad"
        user.firstName = "newUser"
        user.lastName = "smith"
        user.register({ u in
            self.login(user)
            }, failure: { error in
                if error.code == 409 {
                    self.login(user)
                    return
                }
                print("[ERROR] \(error.localizedDescription)")
        })
    }
    
    func showChatList() {
        let c = MMXChatListViewController()
        //c.delegate = self
        // c.contactsPickerDelegate = self
        c.appearance.tintColor = self.view.tintColor
        c.view.tintColor = c.appearance.tintColor
        currentController = c
        self.navigationController?.pushViewController(c, animated: true)
        //self.presentViewController(c, animated: true, completion: nil)
    }
    
    
    func login (user : MMUser) {
        let cred = NSURLCredential.init(user: user.userName, password: user.password, persistence: .None)
        MMUser.login(cred, rememberMe: false, success: {
            //            let url = NSURL.init(string: "https://clipartion.com/wp-content/uploads/2015/11/free-clipart-of-happy-person.png")
            //            MMUser.currentUser()?.setAvatarWithURL(url!, success: { url in
            let u = MMUser.init()
            u.userName = "gogo"
            //            let c = MagnetContactsPickerController()
            //            if let datasource = c.pickerDatasource as? DefaultContactsPickerControllerDatasource, let user = MMUser.currentUser() {
            //                datasource.preselectedUsers = [user]
            //            }
            // c.pickerDelegate = self
            
            self.showChatList()
            
            //            c.canChooseContacts = true
            //  c.tableView.allowsSelection = false
            //c.title = "home"
            //self.presentViewController(c, animated: true, completion: nil)
            //self.currentController = c
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
