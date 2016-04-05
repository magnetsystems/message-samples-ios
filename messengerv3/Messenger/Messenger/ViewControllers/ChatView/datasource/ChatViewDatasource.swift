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
    
    
    //MARK: Public Methods
    
    
    override public func mmxControllerLoadMore(channel : MMXChannel?, offset : Int) {
        guard let channel = controller?.chat else { return }
        
        //get request context
        let loadingContext = controller?.loadingContext()
        
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        
        channel.messagesBetweenStartDate(NSDate.distantPast(), endDate: NSDate(), limit: Int32(limit), offset: Int32(offset), ascending: false, success: { [weak self] total , messages in
            
            if loadingContext != self?.controller?.loadingContext() {
                return
            }
            var messagesWithTimestamps : [MMXMessage] = []
            for message in messages {
                if message.timestamp != nil {
                    messagesWithTimestamps.append(message)
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
    }
}
