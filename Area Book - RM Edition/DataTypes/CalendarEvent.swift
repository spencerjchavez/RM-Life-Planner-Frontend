import SwiftUI

class CalendarEvent : Hashable {
    var name: String
    var eventDescription: String
    var eventId: Int
    var relatedGoals: String
    var startInstant: Double
    var startDay: Double
    var duration: Double
    var endInstant: Double
    var endDay: Double
    var rruleString: String
    var recurrenceId: Int
    var isInPast: Bool
    var happened: Bool
    var report: String
    var eventType: Int

    init( eventId: Int, name: String = "", description: String = "", relatedGoals: String = "", startInstant: Double, endInstant: Double, rruleString: String = "", recurrenceId: Int = 0, isInPast: Bool = false, happened: Bool = false, report: String = "", eventType: Int = 0) {
        self.name = name
        self.eventDescription = description
        self.eventId = eventId
        self.relatedGoals = relatedGoals
        self.startInstant = startInstant
        self.startDay = CalendarEventsManager.getDayFromInstant(instant: startInstant)
        self.endInstant = endInstant
        self.endDay = CalendarEventsManager.getDayFromInstant(instant: endInstant)
        self.duration = endInstant - startInstant
        self.rruleString = rruleString
        self.recurrenceId = recurrenceId
        self.isInPast = isInPast
        self.happened = happened
        self.report = report
        self.eventType = eventType
    }
    // specify duration instead of endInstant
    init( eventId: Int, name: String = "", description: String = "", relatedGoals: String = "", startInstant: Double, duration: Double = 60 * 60, rruleString: String = "", recurrenceId: Int = 0, isInPast: Bool = false, happened: Bool = false, report: String = "", eventType: Int = 0) {
        self.name = name
        self.eventDescription = description
        self.eventId = eventId
        self.relatedGoals = relatedGoals
        self.startInstant = startInstant
        self.startDay = CalendarEventsManager.getDayFromInstant(instant: startInstant)
        self.endInstant = startInstant + duration
        self.endDay = CalendarEventsManager.getDayFromInstant(instant: endInstant)
        self.duration = duration
        self.rruleString = rruleString
        self.recurrenceId = recurrenceId
        self.isInPast = isInPast
        self.happened = happened
        self.report = report
        self.eventType = eventType
    }
    
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.eventId == rhs.eventId
    }
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(eventId)
    }
}
