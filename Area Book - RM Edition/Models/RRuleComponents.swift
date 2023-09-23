//
//  RRuleComponents.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/2/23.
//

import Foundation
import EventKit

struct RRuleComponents {
    // FRONT-END MEMBERS ONLY
    enum RepeatPattern : CaseIterable, Identifiable {
        case noRepeat
        case repeatsDaily
        case repeatsWeekly
        case repeatsByDayOfMonth
        case repeatsByWeekOfMonth
        case repeatsYearly
        case customRepeat
        
        var id: RepeatPattern { self }
    }
    var pattern: RepeatPattern
    //customRepeat is "REPEAT EVERY interval WEEKS days"
    var startDate: Date
    var endDate: Date?
    var interval: Int
    var days: [EKWeekday]?
    
    func toEKRecurrenceRule() -> EKRecurrenceRule {
        var end: EKRecurrenceEnd? = nil
        if let endDate = endDate {
            end = EKRecurrenceEnd(end: endDate)
        }
       switch pattern {
       case .noRepeat: //this will not happen
           return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)
       case .repeatsDaily:
           return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)
       case .repeatsWeekly:
           return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: end)
       case .repeatsByDayOfMonth:
           let dc = Calendar.current.dateComponents([.day], from: startDate)
           let day = NSNumber(value: dc.day!)
           return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [day], monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: end)
       case .repeatsByWeekOfMonth:
           let dc = Calendar.current.dateComponents([.weekday, .weekOfMonth], from: startDate)
           let weekday = EKWeekday(rawValue: dc.weekday!)!
           let weekOfMonth = dc.weekOfMonth!
           return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(dayOfTheWeek: weekday, weekNumber: weekOfMonth)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: end)
       case .repeatsYearly:
           return EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: end)
       case .customRepeat:
           var daysOfTheWeek: [EKRecurrenceDayOfWeek] = []
           for day in days! {
               daysOfTheWeek.append(EKRecurrenceDayOfWeek(day))
           }
           return EKRecurrenceRule(recurrenceWith: .weekly, interval: interval, daysOfTheWeek: daysOfTheWeek, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: end)
       }
    }
}
