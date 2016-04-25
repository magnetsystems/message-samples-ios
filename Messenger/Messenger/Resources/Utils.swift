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

import AFNetworking
import MagnetMax
import UIKit

class UtilsSet {
    
    var completionBlocks : [((image : UIImage?)->Void)] = []
    var set : Set<UIImageView> = Set()
    
    func addCompletionBlock(completion : ((image : UIImage?)->Void)?) {
        if let completion = completion {
            completionBlocks.append(completion)
        }
    }
}


class Utils: NSObject {
    
    
    //MARK: Private Properties
    
    
    private static var downloadObjects : [String : String] = [:]
    private static var loadingURLs : [String : UtilsSet] = [:]
    
    
    //MARK: Magnet helper
    
    
    static func isMagnetEmployee() -> Bool {
        if let currentUser = MMUser.currentUser() where ( currentUser.tags != nil && currentUser.tags.contains(kMagnetSupportTag) ) {
            return true
        }
        return false
    }
}
