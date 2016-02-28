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

public class MagnetViewController : MMViewController {
    
    public var magnetNavigationBar : UINavigationBar?
    public var magnetNavigationItem : UINavigationItem?
    private let navBarHeight : CGFloat = 54.0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = underlyingViewController() {
            self.addChildViewController(viewController)
            viewController.view.frame = self.view.frame;
            viewController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            self.view.addSubview(viewController.view);
            viewController.didMoveToParentViewController(self);
        }
        
        let nav = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navBarHeight))
        nav.autoresizingMask = .FlexibleWidth
        self.view.addSubview(nav)
        let navItem = UINavigationItem()
        nav.items = [navItem]
        magnetNavigationItem = navItem
        magnetNavigationBar = nav
        magnetNavigationBar?.hidden = true
    }

    internal func setMagnetNavBar(leftItems leftItems:[UIBarButtonItem]?, rightItems:[UIBarButtonItem]?, title : String?) {
        var willHide = false
        if leftItems == nil && rightItems == nil && title == nil  {
            magnetNavigationBar?.hidden = true
            willHide = true
        }
        
        if let tableViewController = underlyingViewController() as? MMTableViewController, let navBar = self.magnetNavigationBar {
            var currentInsets = tableViewController.tableView.contentInset
            currentInsets.top = willHide ? 0 : navBar.frame.size.height
            tableViewController.tableView.contentInset = currentInsets
        }
        
        if willHide {
            return
        }
        
        magnetNavigationBar?.hidden = false
        self.magnetNavigationItem?.leftBarButtonItems = leftItems
        self.magnetNavigationItem?.rightBarButtonItems = rightItems
        self.magnetNavigationItem?.title = title
    }
    
    internal func underlyingViewController() -> UIViewController? {
        return nil
    }
}
