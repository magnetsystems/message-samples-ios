//
//  DateFormatter.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/26/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

class DateFormatter {
    
    let formatter = NSDateFormatter()
    
    init() {
        formatter.locale = NSLocale.currentLocale()
        formatter.timeZone = NSTimeZone(name: "GMT")
    }
    
    func relativeDateForDate(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .NoStyle)
    }
    
    func timeForDate(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    func dateForStringTime(stringTime: String) -> NSDate? {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.dateFromString(stringTime)
    }
    
    func currentTimeStamp() -> String {
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.stringFromDate(NSDate())
    }
    
    func displayTime(stringTime: String) -> String! {
        let secondsInDay: NSTimeInterval = 24 * 60 * 60
        let yesturday = NSDate(timeInterval: -secondsInDay, sinceDate: NSDate())
        
        if let lastPublishedTime = dateForStringTime(stringTime) {
            let result = yesturday.compare(lastPublishedTime)
            if result == .OrderedAscending {
                return timeForDate(lastPublishedTime)
            } else {
                return relativeDateForDate(lastPublishedTime)
            }
        }
        
        return stringTime
    }

}
