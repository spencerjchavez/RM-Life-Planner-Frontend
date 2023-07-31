//
//  Recurrence.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/8/23.
//

import Foundation
import EventKit

struct Recurrence {
    
    var recurrenceId: Int?
    var userId: Int
    var rruleString: String
    var startInstant: Double
    
    var eventName: String?
    var eventDescription: String?
    var eventDuration: String?
    
    var todoName: String?
    var todoTimeframe: String?
    
    var goalName: String?
    var goalDesireId: Int?
    var goalHowMuch: Int?
    var goalMeasuringUnits: String?
    var goalTimeframe: Int?
    
    
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
    var end: Double
    var interval: Int
    var days: [EKWeekday]?
    
    //event only recurrence
    init(userId: Int, startInstant: Double, eventName: String, eventDescription: String, eventDuration: String, pattern: RepeatPattern, interval: Int, days: [EKWeekday], end: Double) {
        self.userId = userId
        self.startInstant = startInstant
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventDuration = eventDuration
        self.pattern = pattern
        self.end = end
        self.interval = interval
        self.days = days
        self.rruleString = generateRRuleStr()
    }
    
    //todo only recurrence
    init(userId: Int, startInstant: Double, todoName: String, todoTimeframe: String, pattern: RepeatPattern, interval: Int, days: [EKWeekday], end: Double) {
        self.userId = userId
        self.startInstant = startInstant
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.pattern = pattern
        self.end = end
        self.interval = interval
        self.days = days
        self.rruleString = generateRRuleStr()
    }
    
    //goal + todo recurrence
    init(userId: Int, startInstant: Double, todoName: String, todoTimeframe: String, goalName: String, goalDesireId: Int, goalHowMuch: Int, goalMeasuringUnits: String, goalTimeframe: Int, pattern: RepeatPattern, interval: Int, days: [EKWeekday], end: Double) {
        self.userId = userId
        self.startInstant = startInstant
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.goalName = goalName
        self.goalDesireId = goalDesireId
        self.goalHowMuch = goalHowMuch
        self.goalMeasuringUnits = goalMeasuringUnits
        self.goalTimeframe = goalTimeframe
        self.pattern = pattern
        self.end = end
        self.interval = interval
        self.days = days
        self.rruleString = generateRRuleStr()
    }
    
    //goal + todo + event recurrence
    init(userId: Int, startInstant: Double, eventName: String, eventDescription: String, eventDuration: String, todoName: String, todoTimeframe: String, goalName: String, goalDesireId: Int, goalHowMuch: Int, goalMeasuringUnits: String, goalTimeframe: Int, pattern: RepeatPattern, interval: Int, days: [EKWeekday], end: Double) {
        self.userId = userId
        self.startInstant = startInstant
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventDuration = eventDuration
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.goalName = goalName
        self.goalDesireId = goalDesireId
        self.goalHowMuch = goalHowMuch
        self.goalMeasuringUnits = goalMeasuringUnits
        self.goalTimeframe = goalTimeframe
        self.pattern = pattern
        self.end = end
        self.interval = interval
        self.days = days
        self.rruleString = generateRRuleStr()
    }
    
    
    func generateRRuleStr() -> String {
        //TODO: do it
        return ""
    }
    
    /*
     USE IN FUTURE IF WANT TO GENERATE RECURRENCE INSTANCES ON THE CLIENT-SIDE
     private func calculateRRule() -> EKRecurrenceRule {
        var end = EKRecurrenceEnd(end: Date())
        switch pattern {
        case .noRepeat: //this will not happen
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)
        case .repeatsDaily:
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: end)
        case .repeatsWeekly:
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: end)
        case .repeatsByDayOfMonth:
            let dc = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: start))
            let day = NSNumber(value: dc.day!)
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [day], monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: end)
        case .repeatsByWeekOfMonth:
            let dc = Calendar.current.dateComponents([.weekday, .weekOfMonth], from: Date(timeIntervalSince1970: start))
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
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: interval!, daysOfTheWeek: daysOfTheWeek, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: end)
        }
    }
    */
}
