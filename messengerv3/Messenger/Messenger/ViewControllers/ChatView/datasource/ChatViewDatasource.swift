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

public class ChatViewDatasource : DefaultChatViewControllerDatasource {
    
    var numberOfMessagesWithoutTimeStamps : Int = 0
    var blockedUserManager = BlockedUserManager()
    
    
    //MARK: Public Methods
    
    
    override public func mmxControllerLoadMore(channel : MMXChannel?, offset : Int) {
        guard let channel = controller?.chat else { return }
        
        let loadingContext = self.controller?.loadingContext()
        
        blockedUserManager.getBlockedUsers({ users in
            //get request context
            
            if loadingContext != self.controller?.loadingContext() {
                return
            }
            
            self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
            
            if offset == 0 {
                self.numberOfMessagesWithoutTimeStamps = 0
            }
            
            let messageOffset = self.numberOfMessagesWithoutTimeStamps + offset
            channel.messagesBetweenStartDate(NSDate.distantPast(), endDate: NSDate(), limit: Int32(self.limit), offset: Int32(messageOffset), ascending: false, success: { [weak self] total , messages in
                
                if loadingContext != self?.controller?.loadingContext() {
                    return
                }
                var messagesWithTimestamps : [MMXMessage] = []
                for message in messages {
                    if let sender = message.sender, let blockedUserManager = self?.blockedUserManager where message.timestamp != nil && !blockedUserManager.isUserBlocked(sender) {
                        messagesWithTimestamps.append(message)
                    } else {
                        self?.numberOfMessagesWithoutTimeStamps += 1
                    }
                }
                self?.hasMoreUsers = (offset + Int32(messages.count)) < total
                
                self?.controller?.append(messagesWithTimestamps)
                if offset == 0 {
                    self?.controller?.scrollToBottomAnimated(false)
                }
                DDLogVerbose("[Retrieved Messages] - (\(messages.count))")
                }, failure: { error in
                    DDLogError("[Error] - \(error.localizedDescription)")
            })
            }, failure: { error in
                //error
        })
    }
}
