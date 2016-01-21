/*
* Copyright (c) 2015 Magnet Systems, Inc.
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

class UserRetrievalViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var criteriaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    
    
    // MARK: public properties
    
    
    var users : [MMUser] = []
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMode = .ByID
    }
    
    
    // MARK: Private implementations
    
    
    private enum CurrentMode {
        case ByID
        case ByUserName
    }
    
    private var currentMode: CurrentMode = .ByID {
        didSet {
            switch currentMode {
            case .ByID:
                searchTextField.placeholder = "userID1, userID2, userID3"
                searchTextField.text = MMUser.currentUser()?.userID
            case .ByUserName:
                searchTextField.placeholder = "userName1, userName2, userName3"
                searchTextField.text = MMUser.currentUser()?.userName
            }
        }
    }
    
    
    // MARK: Actions
    
    
    @IBAction func criteriaChanged() {
        if criteriaSegmentedControl.selectedSegmentIndex == 0 {
            currentMode = .ByID
        } else if criteriaSegmentedControl.selectedSegmentIndex == 1 {
            currentMode = .ByUserName
        }
    }
    
    @IBAction func retrieveUsers(sender: UIBarButtonItem) {
        if let searchString = searchTextField.text {
            let values = searchString.characters.split(",").map { String($0).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
            switch currentMode {
            case .ByID:
                MMUser.usersWithUserIDs(values, success: { [weak self] users in
                    self?.users = users
                    self?.usersTableView.reloadData()
                }, failure: { error in
                    print("[ERROR]: \(error.localizedDescription)")
                })
            case .ByUserName:
                MMUser.usersWithUserNames(values, success: { [weak self] users in
                    self?.users = users
                    self?.usersTableView.reloadData()
                }, failure: { error in
                    print("[ERROR]: \(error.localizedDescription)")
                })
            }
        }
    }
    
}

extension UserRetrievalViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCellIdentifier", forIndexPath: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.userName
        
        return cell
    }
}
