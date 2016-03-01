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

class ViewController: UIViewController, ContactsPickerControllerDelegate, ChatListControllerDelegate {
    var currentController : UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //generateUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = MMUser.init()
        user.password = "gogogo"
        user.userName = "bob@bob.com"
        user.firstName = "bob"
        user.lastName = "smith"
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
    
    func chatListDidSelectChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) {
        print("Selected \(channel.name)")
        let chatViewController = MagnetChatViewController.init(channel : channel)
        let myId = MMUser.currentUser()?.userID
        
        let subscribers = channelDetails.subscribers.filter({$0.userId !=  myId})
        
        if subscribers.count > 1 {
            chatViewController.title = "Group"
        } else {
            chatViewController.title = subscribers.map({$0.displayName}).reduce("", combine: {$0 == "" ? $1 : $0 + ", " + $1})
        }
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
        //self.currentController?.presentViewController(chatViewController, animated: true, completion: nil)
    }
    
    func chatListCanLeaveChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse) -> Bool {
        return false
    }
    
    func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        
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
            let c = MagnetChatListViewController()
            c.delegate = self
            //            c.appearance.tintColor = self.view.tintColor
            //            c.canChooseContacts = true
            //  c.tableView.allowsSelection = false
            c.title = "home"
            self.navigationController?.pushViewController(c, animated: true)
            //self.presentViewController(c, animated: true, completion: nil)
            self.currentController = c
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

