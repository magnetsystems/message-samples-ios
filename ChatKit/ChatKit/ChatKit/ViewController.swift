//
//  ViewController.swift
//  ChatKit
//
//  Created by Lorenzo Stanton on 2/10/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import UIKit
import ChatKit
import MagnetMax

public class ChatListDatasource : DefaultChatListControllerDatasource {
    public func mmxListDidCreateCell(cell: UITableViewCell) {
        if let sumCell = cell as? ChatListCell {
            sumCell.lblMessage?.textColor = UIColor.whiteColor()
            sumCell.lblSubscribers?.textColor = UIColor.whiteColor()
        }
    }
}

public class MyChatListController : MMXChatListViewController {
    
    var _chatViewController : MMXChatViewController?
    public override weak var currentChatViewController : MMXChatViewController? {
        set {
            var controller : MMXChatViewController?
            if let channel = newValue?.channel {
                controller = MyChatViewController(channel: channel)
            } else if let users = newValue?.recipients {
                controller = MyChatViewController(recipients: users)
            }
            _chatViewController = controller
        }
        
        get {
            return _chatViewController
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.purpleColor()
        self.cellBackgroundColor = UIColor.orangeColor()
        self.datasource = ChatListDatasource()
    }
}

public class MyChatViewController : MMXChatViewController {
    
    override public var chatDetailsViewController : MMXContactsPickerController? {
        didSet {
            chatDetailsViewController?.tableView.backgroundColor = UIColor.orangeColor()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.yellowColor()
    }
}

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
        user.userName = "john"
        user.firstName = "r"
        user.lastName = "s"
        
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
        //let c : UIViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("home")
        //c.delegate = self
        // c.contactsPickerDelegate = self
        //        c.appearance.tintColor = self.view.tintColor
        //        c.canSearch = true
        // c.view.tintColor = c.appearance.tintColor
        currentController = c
        self.navigationController?.pushViewController(c, animated: true)
        //self.presentViewController(c, animated: true, completion: nil)
    }
    
    func login (user : MMUser) {
        let cred = NSURLCredential.init(user: user.userName, password: user.password, persistence: .None)
        MMUser.login(cred, rememberMe: false, success: {
            //            let url = NSURL.init(string: "https://clipartion.com/wp-content/uploads/2015/11/free-clipart-of-happy-person.png")
            //            MMUser.currentUser()?.setAvatarWithURL(url!, success: { url in
            //            let c = MagnetContactsPickerController()
            //            if let datasource = c.pickerDatasource as? DefaultContactsPickerControllerDatasource, let user = MMUser.currentUser() {
            //                datasource.preselectedUsers = [user]
            //            }
            // c.pickerDelegate = self
            //8a80803e5431d5a9015431d8b9f50002#TestChannel
            MMXChannel.channelForID("8a80803e5431d5a9015431d8b9f50002#TestChannel", success: { ch in
            print("channel")
            }, failure: {error in
            print("error \(error.localizedDescription)")
            })
            self.showChatList()
//            MMXChannel.createWithName("TestChannel", summary: "", isPublic: false, publishPermissions: .Anyone, success: { (channel) in
//                print(channel.channelID)
//                }, failure: { (error) in
//                    
//            })
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

