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

public class DefaultContactsPickerControllerDatasource : NSObject, ContactsPickerControllerDatasource  {
   
    
    //MARK: Public Variables
    
    
    public weak var magnetPicker : MagnetContactsPickerController?
    public var preselectedUsers : [MMUser] = []
    
    
    // Private Variables
    
    
    public var hasMoreUsers : Bool = true
    public let limit = 30
    
    
    //MARK Public Methods
    
    
    public func searchQuery(searchText : String?) -> String {
        var searchQuery = "userName:*"
        if let text = searchText {
            searchQuery = "userName:*\(text)* OR firstName:*\(text)* OR lastName:*\(text)*"
        }
        
        return searchQuery
    }
    
    
    //MARK: ContactsPickerControllerDatasource
    
    
    public func contactsControllerLoadMore(searchText : String?, offset : Int) {
        
        let searchQuery = self.searchQuery(searchText)
        
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = magnetPicker?.loadingContext()
        MMUser.searchUsers(searchQuery, limit: limit, offset: offset, sort: "lastName:asc", success: { users in
            //check if the request is still valid
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
            
            }, failure: { error in
                print("[ERROR]: \(error.localizedDescription)")
                self.magnetPicker?.reloadData()
        })
    }
    
    public  func contactControllerHasMore() -> Bool {
        return self.hasMoreUsers
    }
    
    public func contactControllerPreselectedUsers() -> [MMUser] {
       return preselectedUsers
    }
    
    public func contactControllerSearchUpdatesContinuously() ->Bool {
        return true
    }
    
    public func contactControllerShowsSectionsHeaders() -> Bool {
        return true
    }
    
    public  func contactControllerShowsSectionIndexTitles() -> Bool {
        return magnetPicker?.contacts().count > 1
    }
    
}
