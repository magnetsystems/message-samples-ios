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
}
