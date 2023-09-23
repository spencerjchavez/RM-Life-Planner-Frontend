//
//  TodoSM.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/3/23.
//

import Foundation

struct TodoSM : Codable {
    var todoId: Int?
    var userId: Int
    
    var name: String
    var startDate: String
    var deadlineDate: String?
    var howMuchPlanned: Double
    
    var recurrenceId: Int?
    var recurrenceDate: String?
    var linkedGoalId: Int?
    
    init(from lm: TodoLM) throws {
        self.todoId = IdsManager.getServerId(from: lm.todoId)
        self.startDate = SQLDateFormatter.toSQLDateString(lm.startDate)
        if let lmDeadline = lm.deadlineDate {
            self.deadlineDate = SQLDateFormatter.toSQLDateString(lmDeadline)
        }
        if let lmRecurrenceId = lm.recurrenceId {
            self.recurrenceId = IdsManager.getServerId(from: lmRecurrenceId)
        }
        if let lmRecurrenceDate = lm.recurrenceDate {
            self.recurrenceDate = SQLDateFormatter.toSQLDateString(lmRecurrenceDate)
        }
        if let lmLinkedGoalId = lm.linkedGoalId {
            self.linkedGoalId = IdsManager.getServerId(from: lmLinkedGoalId)
        }
        self.userId = lm.userId
        self.name = lm.name
        self.howMuchPlanned = lm.howMuchPlanned
    }
}
