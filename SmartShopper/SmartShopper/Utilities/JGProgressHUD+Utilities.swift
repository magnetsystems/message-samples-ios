//
//  JGProgressHUD+Utilities.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/18/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import JGProgressHUD

extension JGProgressHUD {
    static func showText(text: String, view: UIView?) -> JGProgressHUD {
        let hud = JGProgressHUD(style: .Dark)
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.square = true
        hud.showInView(view)
        hud.dismissAfterDelay(2.0)
        hud.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        return hud
    }
}