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
import JSQMessagesViewController
import MMX

class AvatarImage: JSQMessagesAvatarImage {

    
    init(userID: String ) {
        super.init()
        
        MMUser.usersWithUserIDs([userID], success: { (users) -> Void in
            
            let user = users.first
            
            let url = user!.avatarURL()
            print("user avatar url \(url)")
            
            if url!.absoluteString.characters.count > 0 {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL:url!)
                    dispatch_async(dispatch_get_main_queue()) {
                        if data?.length > 0 {
                            print("data \(data?.length)")
                            self.avatarImage = UIImage(data: data!)
                        } else {
                            print("no url content data")
                            self.avatarImage = Utils.noAvatarImageForUser(user!)
                        }
                    }
                }
            } else {
                print("no url")
                self.avatarImage = Utils.noAvatarImageForUser(user!)
            }
            
            }, failure: { (error) -> Void in
                
        })

    }
    
}
