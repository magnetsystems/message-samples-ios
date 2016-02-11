//
//  AvatarImage.swift
//  Messenger
//
//  Created by Vladimir Yevdokimov on 2/11/16.
//  Copyright © 2016 Magnet Systems, Inc. All rights reserved.
//

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
