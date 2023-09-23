import SwiftUI

struct CalendarEventLM : RMLifePlannerLocalModel{
    
    var eventId: Int
    var userId: Int
    var name: String
    var description: String?
    var isHidden: Bool
    
    var startInstant: Date
    var endInstant: Date
    var duration: Double
    
    var linkedTodoId: Int?
    var linkedGoalId: Int?
    var howMuchAccomplished: Double?
    var notes: String?
    
    var recurrenceId: Int?
    var recurrenceDate: Date?

    init(eventId: Int? = nil, userId: Int, name: String, description: String? = nil, isHidden: Bool = false, startInstant: Date, endInstant: Date, linkedGoalId: Int? = nil, linkedTodoId: Int? = nil, howMuchAccomplished: Double? = nil, notes: String? = nil) {
        if let eventId = eventId {
            self.eventId = eventId
        } else {
            self.eventId = try! IdsManager.generateId()
        }
        self.userId = userId
        self.name = name
        self.description = description
        self.isHidden = isHidden
        self.startInstant = startInstant
        self.endInstant = endInstant
        self.duration = startInstant.distance(to: endInstant)
        self.linkedGoalId = linkedGoalId
        self.linkedTodoId = linkedTodoId
        self.howMuchAccomplished = howMuchAccomplished
        self.notes = notes
    }
    
    init(eventId: Int? = nil, userId: Int, name: String, description: String? = nil, isHidden: Bool = false, startInstant: Date, duration: Double, linkedGoalId: Int? = nil, linkedTodoId: Int? = nil, howMuchAccomplished: Double? = nil, notes: String? = nil) {
        self.init(eventId: eventId, userId: userId, name: name, startInstant: startInstant, endInstant: startInstant.addingTimeInterval(duration), linkedGoalId: linkedGoalId, linkedTodoId: linkedTodoId, howMuchAccomplished: howMuchAccomplished, notes: notes)
    }
    init(from sm: CalendarEventSM) throws {
        guard let smEventId = sm.eventId else {
            throw RMLifePlannerError.serverError("event model returned from server is missing an event id")
        }
        eventId = try IdsManager.getOrGenerateLocalId(from: smEventId, modelType: CalendarEventLM.getModelName())
        if let todoId = linkedTodoId {
            self.linkedTodoId = try IdsManager.getOrGenerateLocalId(from: todoId, modelType: TodoLM.getModelName())
        }
        if let goalId = linkedGoalId {
            self.linkedGoalId = try IdsManager.getOrGenerateLocalId(from: goalId, modelType: GoalLM.getModelName())
        }
        if let recurrenceId = recurrenceId {
            self.recurrenceId = try IdsManager.getOrGenerateLocalId(from: recurrenceId, modelType: RecurrenceLM.getModelName())
        }
        self.userId = sm.userId
        self.name = sm.name
        self.description = sm.description
        self.isHidden = sm.isHidden
        self.howMuchAccomplished = sm.howMuchAccomplished
        self.notes = sm.notes
        if let d = SQLDateFormatter.toDate(ymdDate: sm.startDate, hmsTime: sm.startTime) {
            self.startInstant = d
        } else {
            throw RMLifePlannerError.clientError
        }
        if let d = SQLDateFormatter.toDate(ymdDate: sm.endDate, hmsTime: sm.endTime) {
            self.endInstant = d
        } else {
            throw RMLifePlannerError.clientError
        }
        self.duration = self.startInstant.distance(to: self.endInstant)
    }
    mutating func updateStartInstant(_ newStartInstant: Date) {
        self.startInstant = newStartInstant
        self.endInstant = self.startInstant + self.duration
    }
    static func getModelName() -> String {
        return "CalendarEvent"
    }
}
