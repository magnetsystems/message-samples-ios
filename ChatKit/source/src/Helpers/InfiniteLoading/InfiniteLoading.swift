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
    
    
    //MARK: Public Methods
    
    
    public func setNeedsUpdate() {
        if isWaiting || isFinished {
            return
        }
        
        isWaiting = true
        
        for loadMoreBlock in loadMoreBlocks {
            loadMoreBlock()
        }
    }
    
    public func onUpdate(loadMore : (() -> Void)) {
        loadMoreBlocks.append(loadMore)
    }
    
    public func finishUpdating() {
        isWaiting = false
    }
    
    public func startUpdating () {
        isFinished = false
    }
    
    public func stopUpdating() {
        isFinished = true
        isWaiting = false
    }
}