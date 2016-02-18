/*
* Copyright (c) 2015 Magnet Systems, Inc.
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
