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

class UserSearchViewController: UIViewController {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var criteriaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    
    
    // MARK: public properties
    
    
    var users : [MMUser] = []
    
    
    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchParametr = .BeginsWith
    }
    
    
    // MARK: private implementations
    
    
    private enum SearchParametr {
        case BeginsWith
        case EndsWith
    }
    
    private var searchParametr: SearchParametr = .BeginsWith {
        didSet {
            guard let currentUser = MMUser.currentUser() else {
                return
            }
            let userName = currentUser.userName
            switch searchParametr {
            case .BeginsWith:
                let searchQuery = "userName:\(userName.characters.first!)*"
                searchTextField.placeholder = searchQuery
                searchTextField.text = searchQuery
            case .EndsWith:
                let searchQuery = "userName:*\(userName.characters.last!)"
                searchTextField.placeholder = searchQuery
                searchTextField.text = searchQuery
            }
        }
    }
    
    
    // MARK: Actions
    
    
    @IBAction func criteriaChanged() {
        if criteriaSegmentedControl.selectedSegmentIndex == 0 {
            searchParametr = .BeginsWith
        } else if criteriaSegmentedControl.selectedSegmentIndex == 1 {
            searchParametr = .EndsWith
        }
    }
    
    @IBAction func retrieveUsers(sender: UIBarButtonItem) {
        if let searchString = searchTextField.text {
            MMUser.searchUsers(searchString, limit: 10, offset: 0, sort: "userName:asc", success: { [weak self] users in
                self?.users = users
                self?.usersTableView.reloadData()
            }, failure: { error in
                print("[ERROR]: \(error.localizedDescription)")
            })
        }
    }
}

extension UserSearchViewController : UITableViewDataSource {
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
