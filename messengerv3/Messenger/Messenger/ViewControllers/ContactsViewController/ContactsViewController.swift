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
import ChatKit

class ContactsViewController: MMXContactsPickerController {
    
    var channel: MMXChannel! {
        didSet {
            title = channel.name
            updateMuteStatus(true)
        }
    }
    
    var notifier : NavigationNotifier?
    override var barButtonCancel : UIBarButtonItem? {
        set {
            
        }
        get {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = ContactsViewControllerDatasource()
        self.view.tintColor = UIColor(red: 14.0/255.0, green: 122.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        self.notifier = NavigationNotifier(viewController: self, exceptFor : nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func updateMuteStatus(isFirstTime: Bool = false) {
        if channel.isMuted {
            barButtonNext = UIBarButtonItem(title: "Unmute", style: .Plain, target: self, action: #selector(ContactsViewController.unMuteAction))
        } else {
            barButtonNext = UIBarButtonItem(title: "Mute", style: .Plain, target: self, action: #selector(ContactsViewController.muteAction))
        }
        if !isFirstTime {
            navigationItem.rightBarButtonItems = [barButtonNext!]
        }
    }
    
    // MARK: Mute/unmute actions
    
    func muteAction() {
        let aYearFromNow = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: 1, toDate: NSDate(), options: .MatchNextTime)
        barButtonNext?.enabled = false
        channel.muteUntil(aYearFromNow, success: { [weak self] in
            self?.barButtonNext?.enabled = true
            self?.updateMuteStatus()
        }, failure: { [weak self] error in
            self?.barButtonNext?.enabled = true
//            print(error.localizedDescription)
        })
    }
    
    func unMuteAction() {
        barButtonNext?.enabled = false
        channel.unMuteWithSuccess({ [weak self] in
            self?.barButtonNext?.enabled = true
            self?.updateMuteStatus()
        }) { [weak self] error in
            self?.barButtonNext?.enabled = true
//            print(error.localizedDescription)
        }
    }
}
