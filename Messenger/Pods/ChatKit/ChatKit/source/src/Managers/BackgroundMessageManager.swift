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

import CocoaLumberjack
import MagnetMax

@objc public class BackgroundMessageManager: NSObject {
    
    
    //MARK: Public Methods
    
    
    public static var sharedManager = BackgroundMessageManager()
    public var isEnabled = true
    
    
    //MARK: Private Properties
    
    
    private var channels = Set<MMXChannel>()
    private var lastDate = NSDate()
    private var queue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "ChatKit - BackgroundMessageManager"
        queue.underlyingQueue = dispatch_queue_create("ChatKit - BackgroundMessageManager", nil)
        return queue
    }()
    
    
    //MARK: Init
    
    
    override init() {
        super.init()
        
        DDLogVerbose("[BackgroundMessageManager] - setup")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BackgroundMessageManager.start), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BackgroundMessageManager.stop), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: Internal Methods
    
    
    internal func setup() { }
    
    
    //MARK: Private Methods
    
    
    private func fetchMessagesSinceAppBecameInactive(offset : Int, channel : MMXChannel, operation :  MMAsynchronousOperation, completion : ((messages : Set<MMXMessage>) -> Void)) {
        channel.messagesBetweenStartDate(self.lastDate, endDate: NSDate(), limit: 10, offset: Int32(offset), ascending: true, success: {
            total , messages in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                guard !operation.cancelled && !operation.finished else {
                    return
                }
                var notificationMessages = Set<MMXMessage>()
                for msg in messages {
                    var nMSG = MMXMessage()
                    msg.channel = channel
                    notificationMessages.insert(nMSG)
                }
                if total > Int32(messages.count) {
                    let comp : ((messages : Set<MMXMessage>) -> Void) = { messages in
                        notificationMessages.unionInPlace(messages)
                        completion(messages: notificationMessages)
                    }
                    self.fetchMessagesSinceAppBecameInactive(offset + messages.count, channel: channel, operation: operation, completion: comp)
                } else {
                    completion(messages: notificationMessages)
                    operation.finish()
                }
            }
            }, failure: { error in
                operation.finish()
        })
    }
    
    @objc private func start() {
        if lastDate.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            DDLogVerbose("[BackgroundMessageManager] - wake")
            let operation = MMAsyncBlockOperation(with: { [weak queue] operation in
                MMXChannel.subscribedChannelsWithSuccess({ channels in
                    guard !operation.cancelled && !operation.finished else {
                        return
                    }
                    
                    for channel in channels {
                        let operation = MMAsyncBlockOperation(with: { operation in
                            self.fetchMessagesSinceAppBecameInactive(0, channel: channel, operation: operation, completion: { messages in
                                let sortedMessages = messages.sort({self.date($0.0.timestamp).timeIntervalSince1970 < self.date($0.1.timestamp).timeIntervalSince1970})
                                for msg in sortedMessages {
                                    dispatch_sync(dispatch_get_main_queue()) {
                                        NSNotificationCenter.defaultCenter().postNotificationName(MMXDidReceiveMessageNotification, object: nil, userInfo: [MMXMessageKey:msg])
                                    }
                                }
                            })
                        })
                        queue?.addOperation(operation)
                    }
                    operation.finish()
                    }, failure: { error in
                        operation.finish()
                })
                })
            self.queue.addOperation(operation)
        }
    }
    
    private func date(date: NSDate?) -> NSDate {
        return date ?? NSDate()
    }
    
    @objc private func stop() {
        DDLogVerbose("[BackgroundMessageManager] - sleep")
        self.lastDate = NSDate()
        self.queue.cancelAllOperations()
    }
}