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

public class ContactsTableContainerView: UIView {
    
    
    //MARK: Internal Variables
    
    
    @IBOutlet weak var contactsView : ContactsView?
    @IBOutlet weak var parentViewController : UIViewController?
    
    
    //MARK: Overrides
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if let topLayoutGuide = parentViewController?.topLayoutGuide, let contactsView = self.contactsView {
            let topGuide = NSLayoutConstraint(item: contactsView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
            parentViewController?.view.addConstraint(topGuide)
            contactsView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
