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

public class MMViewController: UIViewController {

    
    //MARK: Public Variables
    
    
    public var appearance = MagnetControllerAppearance()
    
    
    //MARK : Init
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupViewController()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewController()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupViewController()
    }

    
    //MARK: Public Methods
    
    
    func setupViewController() { }
    
    func dismiss() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func dismissAnimated() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
