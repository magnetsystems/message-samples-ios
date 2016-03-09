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

public class MMJSQViewController: JSQMessagesViewController, MMViewControllerProtocol {
    
    
    //MARK: Public Variables
    
    
    public var appearance = MagnetControllerAppearance()
    public var magnetNavigationBar : UINavigationBar?
    public var magnetNavigationItem : UINavigationItem?
    
    
    //MARK: PRivate Variables
    
    
    private let navBarHeight : CGFloat = 54.0
    
    
    //MARK : Init
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.setupViewController()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewController()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupViewController()
    }
    
    
    //MARK: Public Methods
    
    
    public func setMagnetNavBar(leftItems leftItems:[UIBarButtonItem]?, rightItems:[UIBarButtonItem]?, title : String?) {
        var willHide = false
        if leftItems == nil && rightItems == nil && title == nil  {
            magnetNavigationBar?.hidden = true
            willHide = true
        }
        
        if let navBar = self.magnetNavigationBar {
            let jsqViewController = self as JSQMessagesViewController
            let top = willHide ? 0 : navBar.frame.size.height
            jsqViewController.topContentAdditionalInset = top
        }
        
        if willHide {
            return
        }
        
        magnetNavigationBar?.hidden = false
        self.magnetNavigationItem?.leftBarButtonItems = leftItems
        self.magnetNavigationItem?.rightBarButtonItems = rightItems
        self.magnetNavigationItem?.title = title
    }
    
    public func setupViewController() {
        if #available(iOS 9.0, *) {
            self.loadViewIfNeeded()
        } else {
            if let _ = self.view { }
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
    
    public func dismiss() {
        if self.navigationController != nil {
            self.navigationController?.popViewControllerAnimated(false)
        } else  {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    public func dismissAnimated() {
        if self.navigationController != nil {
            self.navigationController?.popViewControllerAnimated(true)
        } else  {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
