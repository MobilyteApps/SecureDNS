//
//  Date+Ex.swift
//   ChatterBox
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2019 Jitendra Kumar. All rights reserved.
//

import Foundation


//MARK:- EXTENSION FOR DATE
extension Date {
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    func futureDate(_ component: Calendar.Component = .day, value: Int = 14)->Date{
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    func get(_ component: Calendar.Component = .day,calendar: Calendar = Calendar.current)->Int{
        return calendar.component(component, from: self)
    }
    
}

extension Date{
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs:Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedSame ? true : false
    }
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func >(lhs:Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedDescending
    }
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func >=(lhs:Date,rhs: Date) -> Bool {
        return (lhs.compare(rhs) == .orderedDescending || lhs.compare(rhs) == .orderedSame)
    }
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func <(lhs:Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == .orderedAscending
    }
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func <=(lhs:Date, rhs: Date) -> Bool {
        return (lhs.compare(rhs) == .orderedAscending || lhs.compare(rhs) == .orderedSame)
    }
    
    
    
    
}




