import SwiftUI

struct CalendarEvent : Hashable {
    var eventId: Int?
    var usedId: Int
    var name: String
    var description: String
    var isHidden: Bool
    
    var startInstant: Double
    var endInstant: Double
    var duration: Double? // do not need to pass to server
    
    var linkedGoalId: Int?
    var linkedTodoId: Int?
    var recurrenceId: Int?

    init(eventId: Int? = nil, usedId: Int, name: String, description: String, isHidden: Bool = false, startInstant: Double, endInstant: Double, duration: Double? = nil, linkedGoalId: Int? = nil, linkedTodoId: Int? = nil, recurrenceId: Int? = nil) {
        self.eventId = eventId
        self.usedId = usedId
        self.name = name
        self.description = description
        self.isHidden = isHidden
        self.startInstant = startInstant
        self.endInstant = endInstant
        self.duration = duration
        self.linkedGoalId = linkedGoalId
        self.linkedTodoId = linkedTodoId
        self.recurrenceId = recurrenceId
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.eventId == rhs.eventId && lhs.startInstant == rhs.startInstant
    }
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(eventId)
    }
}
