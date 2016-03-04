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

public class SubscribersDatasource : DefaultContactsPickerControllerDatasource {
    var channel : MMXChannel?
    
    //MARK: ContactsPickerControllerDatasource
    
    override public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = self.magnetPicker?.loadingContext()
        
        self.channel?.subscribersWithLimit(Int32(self.limit), offset: Int32(offset), success: { (num, users) -> Void in
            if loadingContext != self.magnetPicker?.loadingContext() {
                return
            }
            
            if users.count == 0 {
                self.hasMoreUsers = false
                self.magnetPicker?.reloadData()
                return
            }
            
            if let picker = self.magnetPicker {
                //append users, reload data or insert data
                picker.appendUsers(users)
            }
            }, failure: { _ in
                self.magnetPicker?.reloadData()
        })
    }
    
    override public func mmxContactsControllerShowsSectionIndexTitles() -> Bool {
        return false
    }
    override public func mmxContactsControllerShowsSectionsHeaders() -> Bool {
        return false
    }
}

extension MagnetChatViewController : ChatViewControllerDelegate {
    override public func viewDidLoad() {
        super.viewDidLoad()
       
        let rightBtn = UIBarButtonItem.init(title: "Details", style: .Plain, target: self, action: "detailsAction")
        self.navigationItem.rightBarButtonItem = rightBtn
        self.delegate = self
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateRightBtn()
    }
    
    public func updateRightBtn() {
        self.navigationItem.rightBarButtonItem?.enabled = self.channel != nil
    }
    
    public func chatDidCreateChannel(channel : MMXChannel) {
        self.updateRightBtn()
    }
    
    public func mmxChatDidCreateChannel(channel : MMXChannel) {
        updateRightBtn()
    }
    
    public func mmxChatDidSendMessage(message : MMXMessage) { }
    
    public func mmxChatDidRecieveMessage(message : MMXMessage) { }
    
    func detailsAction() {
        
        if let currentUser = MMUser.currentUser() {
            let contacts = MagnetContactsPickerController(disabledUsers: [currentUser])
            contacts.barButtonNext = nil
            let subDatasource = SubscribersDatasource()
            subDatasource.magnetPicker = contacts
            contacts.datasource = subDatasource
            subDatasource.channel = self.channel
            contacts.tableView.allowsSelection = false
            contacts.canSearch = false
            contacts.title = "In Group"
            self.navigationController?.pushViewController(contacts, animated: true)
        }
        
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
        user.userName = "user5"
        user.firstName = "auser"
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
        let c = MagnetChatListViewController()
        //c.delegate = self
        // c.contactsPickerDelegate = self
        c.appearance.tintColor = self.view.tintColor
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

