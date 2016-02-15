//
//  Popup.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/15/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit

class Popup: NSObject {
    
    private let alertController: UIAlertController
    
    init(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let closeAction = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(closeAction)
        
        alertController = alert
    }
    
    func presentForController(controller: UIViewController) {
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addAction(action: UIAlertAction) {
        alertController.addAction(action)
    }

}
