//
//  Goal.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct GoalLM : RMLifePlannerLocalModel {
    
    var goalId: Int
    var desireId: Int
    var userId: Int
    var name: String
    var howMuch: Double
    var measuringUnits: String?
    var startDate: Date
    var deadlineDate: Date?
    var priorityLevel: Int
    var recurrenceId: Int?
    var recurrenceDate: Date?

    
    init(goalId: Int? = nil, desireId: Int, userId: Int, name: String, howMuch: Double, measuringUnits: String? = nil, startDate: Date, deadlineDate: Date? = nil, priorityLevel: Int) {
        if let goalId = goalId {
            self.goalId = goalId
        } else {
            self.goalId = try! IdsManager.generateId()
        }
        self.desireId = desireId
        self.userId = userId
        self.name = name
        self.howMuch = howMuch
        self.measuringUnits = measuringUnits
        self.startDate = startDate
        self.deadlineDate = deadlineDate
        self.priorityLevel = priorityLevel
    }
    
    init(from sm: GoalSM) throws {
        guard let smGoalId = sm.goalId else {
            throw RMLifePlannerError.serverError("server goal model did not contain goalId")
        }
        self.goalId = try IdsManager.getOrGenerateLocalId(from: smGoalId, modelType: GoalLM.getModelName())
        desireId = try IdsManager.getOrGenerateLocalId(from: sm.desireId, modelType: DesireLM.getModelName())
        if let recurrenceId = recurrenceId {
            self.recurrenceId = try IdsManager.getOrGenerateLocalId(from: recurrenceId, modelType: RecurrenceLM.getModelName())
        }
        self.userId = sm.userId
        self.name = sm.name
        self.howMuch = sm.howMuch
        self.measuringUnits = sm.measuringUnits
        if let d = SQLDateFormatter.toDate(ymdDate: sm.startDate) {
            self.startDate = d
        } else {
            throw RMLifePlannerError.clientError
        }
        if let smDeadlineDate = sm.deadlineDate {
            if let d = SQLDateFormatter.toDate(ymdDate: smDeadlineDate) {
                self.deadlineDate = d
            } else {
                throw RMLifePlannerError.clientError
            }
        }
        self.priorityLevel = sm.priorityLevel
        if let smRecurrenceDate = sm.recurrenceDate {
            if let d = SQLDateFormatter.toDate(ymdDate: smRecurrenceDate) {
                self.recurrenceDate = d
            } else {
                throw RMLifePlannerError.clientError
            }
        }
    }
    static func getModelName() -> String {
        return "Goal"
    }
}
