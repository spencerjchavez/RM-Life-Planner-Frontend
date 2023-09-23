//
//  Recurrence.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/8/23.
//

import Foundation
import EventKit

struct RecurrenceLM {
    enum Timeframe : String, Codable {
        case INDEFINITE
        case DAY
        case WEEK
        case MONTH
        case YEAR
    }
    var recurrenceId: Int
    var userId: Int
    var rrule: EKRecurrenceRule
    var startInstant: Date
    
    var eventName: String?
    var eventDescription: String?
    var eventDuration: Double?
    
    var todoName: String?
    var todoTimeframe: Timeframe?
    var todoHowMuchPlanned: Double?
    
    var goalName: String?
    var goalDesireId: Int?
    var goalHowMuch: Double?
    var goalMeasuringUnits: String?
    var goalTimeframe: Timeframe?
    
    
    //event only recurrence
    init(userId: Int, rrule: EKRecurrenceRule, startInstant: Date, eventName: String, eventDescription: String, eventDuration: Double) {
        self.recurrenceId = try! IdsManager.generateId()
        self.userId = userId
        self.rrule = rrule
        self.startInstant = startInstant
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventDuration = eventDuration
    }
    
    //todo only recurrence
    init(userId: Int, rrule: EKRecurrenceRule, startInstant: Date, todoName: String, todoTimeframe: Timeframe, todoHowMuchPlanned: Double) {
        self.recurrenceId = try! IdsManager.generateId()
        self.userId = userId
        self.rrule = rrule
        self.startInstant = startInstant
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.todoHowMuchPlanned = todoHowMuchPlanned
    }
    
    //goal + todo recurrence
    init(userId: Int, rrule: EKRecurrenceRule, startInstant: Date, todoName: String, todoTimeframe: Timeframe, todoHowMuchPlanned: Double, goalName: String, goalDesireId: Int, goalHowMuch: Double, goalMeasuringUnits: String, goalTimeframe: Timeframe) {
        self.recurrenceId = try! IdsManager.generateId()
        self.userId = userId
        self.rrule = rrule
        self.startInstant = startInstant
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.todoHowMuchPlanned = todoHowMuchPlanned
        self.goalName = goalName
        self.goalDesireId = goalDesireId
        self.goalHowMuch = goalHowMuch
        self.goalMeasuringUnits = goalMeasuringUnits
        self.goalTimeframe = goalTimeframe
    }
    
    //goal + todo + event recurrence
    init(userId: Int, rrule: EKRecurrenceRule, startInstant: Date, eventName: String, eventDescription: String, eventDuration: Double, todoName: String, todoTimeframe: Timeframe, todoHowMuchPlanned: Double, goalName: String, goalDesireId: Int, goalHowMuch: Double, goalMeasuringUnits: String, goalTimeframe: Timeframe, rruleString: String) {
        self.recurrenceId = try! IdsManager.generateId()
        self.userId = userId
        self.rrule = rrule
        self.startInstant = startInstant
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventDuration = eventDuration
        self.todoName = todoName
        self.todoTimeframe = todoTimeframe
        self.todoHowMuchPlanned = todoHowMuchPlanned
        self.goalName = goalName
        self.goalDesireId = goalDesireId
        self.goalHowMuch = goalHowMuch
        self.goalMeasuringUnits = goalMeasuringUnits
        self.goalTimeframe = goalTimeframe
    }
    init(from sm: RecurrenceSM) throws {
        guard let smRecurrenceId = sm.recurrenceId else {
            throw RMLifePlannerError.serverError("server's recurrence model did not contain a recurrence id")
        }
        self.recurrenceId = try IdsManager.getOrGenerateLocalId(from: smRecurrenceId, modelType: RecurrenceLM.getModelName())
        self.userId = sm.userId
        if let d = SQLDateFormatter.toDate(ymdDate: sm.startDate, hmsTime: sm.startTime) {
            self.startInstant = d
        } else {
            throw RMLifePlannerError.clientError
        }
        self.eventName = sm.eventName
        self.eventDescription = sm.eventDescription
        self.eventDuration = sm.eventDuration
        self.todoName = sm.todoName
        self.todoTimeframe = sm.todoTimeframe
        self.todoHowMuchPlanned = sm.todoHowMuchPlanned
        self.goalName = sm.goalName
        if let smGoalDesireId = sm.goalDesireId {
            self.goalDesireId = try! IdsManager.getOrGenerateLocalId(from: smGoalDesireId, modelType: GoalLM.getModelName())
        }
        self.goalHowMuch = sm.goalHowMuch
        self.goalMeasuringUnits = sm.goalMeasuringUnits
        self.goalTimeframe = sm.goalTimeframe
        self.rrule = EKRecurrenceRule(string: sm.rruleString)
    }
    static func == (lhs: RecurrenceLM, rhs: RecurrenceLM) -> Bool {
        return lhs.recurrenceId == rhs.recurrenceId
    }
    static func getModelName() -> String {
        return "Recurrence"
    }
}
