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

import Foundation

public class InfiniteLoading {
    
    
    //MARK: Public Variables
    
    
    public private(set) var isFinished : Bool = false
    
    
    //MARK: Private Variables
    
    
    private var isWaiting = false
    private var loadMoreBlocks : [(() -> Void)] = []
    private var doneLoadingBlocks : [(() -> Void)] = []
    private let lock = NSLock()
    private var queue : dispatch_queue_t = dispatch_queue_create("infLD", nil)
    
    
    //MARK: Public Methods
    
    
    public func setNeedsUpdate() {
        dispatch_async(queue, {
            self.lock.lock()
            if self.isWaiting || self.isFinished {
                self.lock.unlock()
                return
            }
            
            self.isWaiting = true
            dispatch_sync(dispatch_get_main_queue(), {
                for block in self.loadMoreBlocks {
                    block()
                }
            })
            self.lock.unlock()
        })
    }
    
    public func onUpdate(loadMore : (() -> Void)) {
        dispatch_async(queue, {
            self.lock.lock()
            self.loadMoreBlocks.append(loadMore)
            self.lock.unlock()
        })
    }
    
    public func onDoneUpdating(doneLoading : (() -> Void)) {
        dispatch_async(queue, {
            self.lock.lock()
            self.doneLoadingBlocks.append(doneLoading)
            self.lock.unlock()
        })
    }
    
    public func finishUpdating() {
        dispatch_async(queue, {
            self.lock.lock()
            self.isWaiting = false
            self.lock.unlock()
            dispatch_sync(dispatch_get_main_queue(), {
                for block in self.doneLoadingBlocks {
                    block()
                }
            })
        })
    }
    
    public func startUpdating () {
        dispatch_async(queue, {
            self.lock.lock()
            self.isFinished = false
            self.lock.unlock()
        })
    }
    
    public func stopUpdating() {
        dispatch_async(queue, {
            self.lock.lock()
            self.isFinished = true
            self.finishUpdating()
            self.lock.unlock()
        })
    }
}