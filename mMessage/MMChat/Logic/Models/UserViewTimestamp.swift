//
//  UserViewTimestamp.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/26/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit

class UserViewTimestamp: NSObject, NSCoding {

    let userName: String
    let date: NSDate
    
    init(userName: String, date: NSDate) {
        self.userName = userName
        self.date = date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("userName") as! String
        let date = aDecoder.decodeObjectForKey("date") as! NSDate
        self.init(userName: name, date: date)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userName, forKey: "userName")
        aCoder.encodeObject(date, forKey: "date")
    }
    
}
