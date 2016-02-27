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
import MagnetMax

public class MagnetThreadsViewController: MagnetViewController, ContactsPickerControllerDelegate {
    private var underlyingThreadsViewController = HomeViewController.init()
    private var chooseContacts : Bool = true
    public var canChooseContacts :Bool? {
        didSet {
            if let can = canChooseContacts {
                chooseContacts = can
                generateNavBars()
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
    }
    
    override internal func underlyingViewController() -> UIViewController? {
        return underlyingThreadsViewController
    }
    
    private func generateNavBars() {
        if chooseContacts {
            let rightBtn = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addContactAction")
            if self.navigationController != nil {
                navigationItem.rightBarButtonItem = rightBtn
            } else {
                self.setMagnetNavBar(leftItems: nil, rightItems: [rightBtn], title: self.title)
            }
        }
    }
    
    override func setupViewController() {
        if let user = MMUser.currentUser() {
            self.title = "\(user.firstName ?? "") \(user.lastName ?? "")"
        }
        
        if self.title?.characters.count == 1 {
            self.title = MMUser.currentUser()?.userName
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    //MARK: - ContactsViewControllerDelegate
    

    public func contactsControllerDidFinish(with selectedUsers: [MMUser]) {
        
    }
    
    public func reloadData() {
        underlyingThreadsViewController.refreshChannelDetail()
    }
    
    
    // MARK: Actions
    
    
    func addContactAction() {
        let c = MagnetContactsPickerController(disabledUsers: [MMUser.currentUser()!])
        c.pickerDelegate = self
        
        if let nav = navigationController {
            nav.pushViewController(c, animated: true)
        } else {
            self.presentViewController(c, animated: true, completion: nil)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
