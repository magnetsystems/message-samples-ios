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
    
    func dayOfTheWeek(date: NSDate) -> String {
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EEEE"
        return dayFormatter.stringFromDate(date)
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
        let now = NSDate()
        
        let components = NSCalendar.currentCalendar().components([.Day , .Month, .Year ], fromDate: now)
        let midnight = NSCalendar.currentCalendar().dateFromComponents(components)
        let secondsInWeek: NSTimeInterval = 24 * 60 * 60 * 7
        let aWeekago = NSDate(timeInterval: -secondsInWeek, sinceDate: NSDate())
        let aMinutesAgo = NSDate(timeInterval: -(1 * 60), sinceDate: NSDate())
        
        if let lastPublishedTime = dateForStringTime(stringTime)  {
            if aMinutesAgo.compare(lastPublishedTime) == .OrderedAscending {
                return "Now"
            } else if midnight?.compare(lastPublishedTime) == .OrderedAscending {
                return timeForDate(lastPublishedTime)
            } else if aWeekago.compare(lastPublishedTime) == .OrderedAscending {
                return dayOfTheWeek(lastPublishedTime)
            } else {
                return relativeDateForDate(lastPublishedTime)
            }
        }
        
        return stringTime
    }
}
