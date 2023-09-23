//
//  Todo.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct TodoLM : RMLifePlannerLocalModel {
    
    var todoId: Int
    var userId: Int
    
    var name: String
    var startDate: Date
    var deadlineDate: Date?
    var howMuchPlanned: Double
    
    var recurrenceId: Int?
    var recurrenceDate: Date?
    var linkedGoalId: Int?
    
    init(userId: Int, name: String, startDate: Date, deadlineDate: Date? = nil, howMuchPlanned: Double, linkedGoalId: Int? = nil) {
        self.todoId = try! IdsManager.generateId()
        self.userId = userId
        self.name = name
        self.startDate = startDate
        self.deadlineDate = deadlineDate
        self.howMuchPlanned = howMuchPlanned
        self.linkedGoalId = linkedGoalId
    }
   
    init(from sm: TodoSM) throws {
        guard let smTodoId = sm.todoId else {
            throw RMLifePlannerError.serverError("todo model returned from server is missing a todo id")
        }
        self.todoId = try IdsManager.getOrGenerateLocalId(from: smTodoId, modelType: TodoLM.getModelName())
        if let smRecurrenceId = sm.recurrenceId {
            self.recurrenceId = try IdsManager.getOrGenerateLocalId(from: smRecurrenceId, modelType: RecurrenceLM.getModelName())
        }
        if let smLinkedGoalId = sm.linkedGoalId {
            self.linkedGoalId = try IdsManager.getOrGenerateLocalId(from: smLinkedGoalId, modelType: GoalLM.getModelName())
        }
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
        if let smRecurrenceDate = sm.recurrenceDate {
            if let d = SQLDateFormatter.toDate(ymdDate: smRecurrenceDate) {
                self.recurrenceDate = d
            } else {
                throw RMLifePlannerError.clientError
            }
        }
        self.userId = sm.userId
        self.name = sm.name
        self.howMuchPlanned = sm.howMuchPlanned
    }
    static func getModelName() -> String {
        return "Todo"
    }
}
