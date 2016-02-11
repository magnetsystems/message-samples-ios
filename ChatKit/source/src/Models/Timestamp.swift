//
//  UserViewTimestamp.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/26/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit

class Timestamp: NSObject {
    
    let date: NSDate
    
    init(date: NSDate) {
        self.date = date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey("date") as! NSDate
        self.init(date: date)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "date")
    }
    
}
