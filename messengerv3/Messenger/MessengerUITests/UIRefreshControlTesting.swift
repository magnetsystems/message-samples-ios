//  UIRefreshControlTesting.swift
//  Messenger
//
//  Created by agordyman on 4/5/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.

import Foundation
import UIKit

//#if TESTING

extension UIRefreshControl {
    
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIRefreshControl.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("_setRefreshControlState:notify:")
            let swizzledSelector = Selector("kp__setRefreshControlState:notify:")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    // MARK: - Method Swizzling
    
    // Overrides so that app idles correctly when running UITests
    func kp__setRefreshControlState(state: Int, notify: Bool) {
        print("state: \(state) notify: \(notify)")
    }
    
}

//#endif
