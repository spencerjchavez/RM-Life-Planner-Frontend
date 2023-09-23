//
//  GoalSM.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/3/23.
//

import Foundation

struct GoalSM : Codable {
    
    var goalId: Int?
    var desireId: Int
    var userId: Int
    var name: String
    var howMuch: Double
    var measuringUnits: String?
    var startDate: String
    var deadlineDate: String?
    var recurrenceId: Int?
    var recurrenceDate: String?
    
    init(from lm: GoalLM) throws {
        self.goalId = IdsManager.getServerId(from: lm.goalId)
        if let desireId = IdsManager.getServerId(from: lm.desireId) {
            self.desireId = desireId
        } else {
            throw RMLifePlannerError.clientError
        }
        if let recurrenceId = lm.recurrenceId {
            if let recurrenceId = IdsManager.getServerId(from: recurrenceId) {
                self.recurrenceId = recurrenceId
            } else { throw RMLifePlannerError.clientError }
        }
        self.startDate = SQLDateFormatter.toSQLDateString(lm.startDate)
        if let lmDeadlineDate = lm.deadlineDate {
            self.deadlineDate = SQLDateFormatter.toSQLDateString(lmDeadlineDate)
        }
        if let lmRecurrenceDate = lm.recurrenceDate {
            self.recurrenceDate = SQLDateFormatter.toSQLDateString(lmRecurrenceDate)
        }
        self.userId = lm.userId
        self.name = lm.name
        self.howMuch = lm.howMuch
        self.measuringUnits = lm.measuringUnits
    }
}
