import SwiftUI

struct CalendarEventSM : Codable {
    
    var eventId: Int?
    var userId: Int
    var name: String
    var description: String?
    var isHidden: Bool
    
    var startDate: String
    var startTime: String
    var endDate: String
    var endTime: String
    
    var linkedTodoId: Int?
    var linkedGoalId: Int?
    var howMuchAccomplished: Double?
    var notes: String?
    
    var recurrenceId: Int?
    var recurrenceDate: String?
    
    init(from lm: CalendarEventLM) {
        self.eventId = IdsManager.getServerId(from: lm.eventId)
        if let linkedGoalId = lm.linkedGoalId {
            self.linkedGoalId = IdsManager.getServerId(from: linkedGoalId)
        }
        if let linkedTodoId = lm.linkedTodoId {
            self.linkedTodoId = IdsManager.getServerId(from: linkedTodoId)
        }
        if let recurrenceId = lm.recurrenceId {
            self.recurrenceId = IdsManager.getServerId(from: recurrenceId)
        }
        if let recurrenceDate = lm.recurrenceDate {
            self.recurrenceDate = SQLDateFormatter.toSQLDateString(recurrenceDate)
        }
        self.userId = lm.userId
        self.name = lm.name
        self.description = lm.description
        self.isHidden = lm.isHidden
        let startStrings = SQLDateFormatter.toSQLDateTimeStrings(lm.startInstant)
        self.startDate = startStrings.0
        self.startTime = startStrings.1
        let endStrings = SQLDateFormatter.toSQLDateTimeStrings(lm.endInstant)
        self.endDate = endStrings.0
        self.endTime = endStrings.1
        self.howMuchAccomplished = lm.howMuchAccomplished
        self.notes = lm.notes
    }
    static func == (lhs: CalendarEventSM, rhs: CalendarEventSM) -> Bool {
        return lhs.eventId == rhs.eventId
    }
}
