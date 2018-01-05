//
//  Date+Extension.swift
//  JobinRecruiter
//
//  Created by Alex on 28/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import Foundation

extension Date {
    
    func toDietDateFormatString() -> String{
        let now = Date()
        let nowComponents = now.getYearMonthDay()
        let selfComponents = self.getYearMonthDay()
        
        let dateFormatter = DateFormatter()
        var timeString = ""
        if nowComponents.year == selfComponents.year {
            if self.isTodayWith(time: now) {
                timeString = "Today"
            }
            else if self.isYesterdayWith(time: now) {
                timeString = "Yesterday"
            }
            else {
                dateFormatter.dateFormat = "MMM d EEE"
                let str = dateFormatter.string(from: self)
                timeString = "\(str)"
            }
        }
        else {
            dateFormatter.dateFormat = "dd MMM yyyy"
            timeString = dateFormatter.string(from: self)
        }
        return timeString
    }
    
    func toDietTimeFormatString() -> String{
        let dateFormatter = DateFormatter()
        var timeString = ""
        
        dateFormatter.dateFormat = "h:mm"
        let str = dateFormatter.string(from: self)
        
        dateFormatter.dateFormat = "a"
        let a = dateFormatter.string(from: self).lowercased()
        timeString = "\(str) \(a)"
        
        return timeString
    }
    
    static func fromString(dateString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
    
    static func fromString(dateString: String, format: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    
    func toDateString(format: String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func getYearMonthDay() -> (year:Int, month:Int, day:Int) {
        let components = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: self)
        return (components.year!, components.month!, components.day!)
    }
    
    func isYesterdayWith(time: Date) -> Bool {
        let timeComponents = time.getYearMonthDay()
        let components = NSDateComponents()
        components.day = timeComponents.day
        components.month = timeComponents.month
        components.year = timeComponents.year
        components.hour = 0
        components.minute = 0
        components.second = 0
        let calendar = Calendar.current
        let justDay = calendar.date(from: components as DateComponents)
        let justLastDay = justDay?.addingTimeInterval(-1*24*60*60)
        if self.timeIntervalSinceReferenceDate < justDay!.timeIntervalSinceReferenceDate && self.timeIntervalSinceReferenceDate >= (justLastDay?.timeIntervalSinceReferenceDate)! {
            return true
        }
        return false
    }
    
    func isTodayWith(time: Date) -> Bool {
        let justDay = time.getJustDay()
        let justNextDay = justDay.addingTimeInterval(1*24*60*60)
        if self.timeIntervalSinceReferenceDate >= justDay.timeIntervalSinceReferenceDate && self.timeIntervalSinceReferenceDate < justNextDay.timeIntervalSinceReferenceDate {
            return true
        }
        return false
    }
    
    func getJustDay() -> Date {
        let timeComponents = self.getYearMonthDay()
        let components = NSDateComponents()
        components.day = timeComponents.day
        components.month = timeComponents.month
        components.year = timeComponents.year
        components.hour = 0
        components.minute = 0
        components.second = 0
        let calendar = Calendar.current
        let justDay = calendar.date(from: components as DateComponents)
        return justDay!
    }
}

/**
 * Extensions for getting date elements.
 **/
extension Date {
    var asAge:Int {
        let calendar = Calendar.current
        let unitFlags:Set<Calendar.Component> = [.year, .month, .day]
        let dateComponentsNow = calendar.dateComponents(unitFlags, from: Date())
        let dateComponentBirth = calendar.dateComponents(unitFlags, from: self)
        
        if ( (dateComponentsNow.month! < dateComponentBirth.month!) ||
            (dateComponentsNow.month! == dateComponentBirth.month!) && (dateComponentsNow.day! < dateComponentBirth.day!) ){
            return dateComponentsNow.year! - dateComponentBirth.year! - 1
        } else {
            return dateComponentsNow.year! - dateComponentBirth.year!
        }
    }
    
    /// Gets hour components of NSDate
    var hour:Int{
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour], from: self)
        return comp.hour!
    }
    
    /// Gets hour components of NSDate
    var minute:Int {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.minute], from: self)
        return comp.minute!
    }
    
    /// Get Year Month Day
    var yearMonthDay:(Int, Int, Int) {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.year, .month, .day], from: self)
        return (comp.year!, comp.month!, comp.day!)
    }
    
    /// Get year component
    var year:Int {
        return yearMonthDay.0
    }
    
    /// Get Month Component
    var month:Int {
        return yearMonthDay.1
    }
    
    /// Get day component
    var day:Int {
        return yearMonthDay.2
    }
    
    /// NDate from year, month, day
    static func date(year:Int, month:Int, day:Int) -> Date?{
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return calendar.date(from: components)
    }
    
    /// Get Date before years
    func dateBefore(years:Int) -> Date! {
        let ymd = Date().yearMonthDay
        return Date.date(year: ymd.0 - years, month: ymd.1, day: ymd.2)
    }
    
    func dateBefore(days:Int) -> Date! {
        let ymd = Date().yearMonthDay
        return Date.date(year: ymd.0, month: ymd.1, day: ymd.2 - days)
    }
    
    static let intervalOfADay = TimeInterval(60 * 60 * 24)
    
    static func intervalOf(days:Int) -> TimeInterval{
        return intervalOfADay * TimeInterval(days)
    }
    
    // Return first day of current month
    func getFirstDateOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: components)
        return startOfMonth!
    }
    
    // Return first last of current month
    func getLastDateOfMonth() -> Date {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        let endOfMonth = calendar.date(byAdding: comps, to: getFirstDateOfMonth())
        return endOfMonth!
    }
}

/**
 * Calculating
 **/
extension Date{
    func dateAfter(days: Int) -> Date {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.day = days
        let resultDate = calendar.date(byAdding: comp, to: self)
        return resultDate!
    }
    
    func dateAfter(months: Int) -> Date {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.month = months
        let resultDate = calendar.date(byAdding: comp, to: self)
        return resultDate!
    }
    
    func dateAfter(years: Int) -> Date {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.year = years
        let resultDate = calendar.date(byAdding: comp, to: self)
        return resultDate!
    }
}

/**
 * Extension for getting difference between twe dates
 **/

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
