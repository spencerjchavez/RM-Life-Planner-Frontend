//
//  RecurrenceSM.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/3/23.
//

import Foundation

struct RecurrenceSM : Codable {
    var recurrenceId: Int?
    var userId: Int
    var rruleString: String
    var startDate: String
    var startTime: String
    
    var eventName: String?
    var eventDescription: String?
    var eventDuration: Double?
    
    var todoName: String?
    var todoTimeframe: RecurrenceLM.Timeframe?
    var todoHowMuchPlanned: Double?
    
    var goalName: String?
    var goalDesireId: Int?
    var goalHowMuch: Double?
    var goalMeasuringUnits: String?
    var goalTimeframe: RecurrenceLM.Timeframe?
    
    init(from lm: RecurrenceLM) throws {
        self.recurrenceId = IdsManager.getServerId(from: lm.recurrenceId)
        self.userId = lm.userId
        let d = SQLDateFormatter.toSQLDateTimeStrings(lm.startInstant)
        self.startDate = d.0
        self.startTime = d.1
        self.eventName = lm.eventName
        self.eventDescription = lm.eventDescription
        self.eventDuration = lm.eventDuration
        self.todoName = lm.todoName
        self.todoTimeframe = lm.todoTimeframe
        self.todoHowMuchPlanned = lm.todoHowMuchPlanned
        self.goalName = lm.goalName
        if let lmGoalDesireId = lm.goalDesireId {
            self.goalDesireId = IdsManager.getServerId(from: lmGoalDesireId)
        }
        self.goalHowMuch = lm.goalHowMuch
        self.goalMeasuringUnits = lm.goalMeasuringUnits
        self.goalTimeframe = lm.goalTimeframe
        let rruleDescription = lm.rrule.description
        if let match = try rruleDescription.firstMatch(of: Regex(".*RRULE ")) {
            let index = rruleDescription.distance(from: rruleDescription.startIndex, to: match.range.upperBound)
            self.rruleString = String(lm.rrule.description.dropFirst(index))
        } else {
            throw RMLifePlannerError.clientError
        }
    }
}
