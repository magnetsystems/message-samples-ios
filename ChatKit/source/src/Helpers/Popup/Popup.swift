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

class Popup: NSObject {
    
    
    //MARK: Private properties
    
    
    private let alertController: UIAlertController
    
    
    //MARK: Init
    
    
    init(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let closeAction = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(closeAction)
        
        alertController = alert
    }
    
    
    //MARK: Public Methods
    
    
    func addAction(action: UIAlertAction) {
        alertController.addAction(action)
    }
    
    func presentForController(controller: UIViewController) {
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
}
