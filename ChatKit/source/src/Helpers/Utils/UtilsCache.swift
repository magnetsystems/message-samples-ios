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

public class UtilsCache : NSCache {
    
    
    //MARK: Overrides
    
    
    override init() {
        super.init()
        registerForNotifications()
    }
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMemoryWarning", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    func didReceiveMemoryWarning() {
        self.removeAllObjects()
    }
    
    
    //MARK: Public Methods
    
    
    public func setObject(obj : AnyObject, forURL : NSURL, cost : Int ) {
        if let path = forURL.path {
            self.setObject(obj, forKey: path, cost : cost)
        }
    }
    
   public func setObject(obj : AnyObject, forURL : NSURL) {
        if let path = forURL.path {
            self.setObject(obj, forKey: path)
        }
    }
    
    public func objectForURL(url : NSURL) -> AnyObject? {
        if let path = url.path {
            return self.objectForKey(path)
        }
        return nil
    }
}