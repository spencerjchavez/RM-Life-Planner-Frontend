//
//  CalendarEventsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/24/23.
//

import Foundation

class CalendarEventsManager {
    private var eventsByDay: [Int: [CalendarEvent]] = [:]
    private var eventsById: [Int: CalendarEvent] = [:]
    private var calendarDayViews: [Int: CalendarDayView] //organized by day
    
    //for drag and dropping events
    //var proposedNewStartDay = 0
    //var proposedNewStartHour = 0.0
    var eventIdToDrop = -1
    
    // TODO: are we working well with the backend? Can I make these arrays more read-only? so that only the backend is making changes to them and we don't have different copies of the same data?
    
    init(events: [CalendarEvent]) throws {
        calendarDayViews = [:]
        try events.forEach{ event in
            //add events into eventsById
            eventsById[event.eventId] = event
            
            //add events into eventsByDay
            try addToEventsByDay(event: event)
        }
    }
    
    func getEventsOnDay(day: Int) -> [CalendarEvent] {
        return eventsByDay[day] ?? []
    }
    func updateEventStartInstant(eventId: Int, newStartInstant: Double) throws {
        let event = eventsById[eventId]!
        
        let oldDayRange = try CalendarEventsManager.getDaysInRange(startDay: event.startDay, endDay: event.endDay)
        let diff = newStartInstant - event.startInstant
        event.startInstant = newStartInstant
        event.endInstant = event.endInstant + diff
        let newStartDay = CalendarEventsManager.getDayFromInstant(instant: event.startInstant)
        event.startDay = newStartDay
        event.endDay = CalendarEventsManager.getDayFromInstant(instant: event.endInstant)
        //update eventsByDay
        for day in oldDayRange {
            let day = Int(day)
            eventsByDay[day]?.removeAll(where: { (item) in item.eventId == eventId })
            refreshDayView(day: day)
        }
        try addToEventsByDay(event: event)
    }
    func updateEventData(eventId: Int, eventData: CalendarEvent) {

    }
    func addToEventsByDay(event: CalendarEvent) throws {
        let days = try CalendarEventsManager.getDaysInRange(startDay: event.startDay, endDay: event.endDay)
        for day in days {
            let day = Int(day)
            
            //let day = Int(event.startDay)
            if eventsByDay[day] == nil { eventsByDay[day] = []}
            var eventsInDay: [CalendarEvent] = eventsByDay[day]!
            // order events by:
            // 1. increasing startInstant
            // 2. decreasing endInstant
            // 3. increasing eventId
            
            //TODO: ADD SUPPORT FOR MULTI-DAY EVENTS
            var eventInserted = false
            for i in eventsInDay.indices {
                // case 1
                if eventsInDay[i].startInstant > event.startInstant {
                    eventsInDay.insert(event, at: i)
                    eventInserted = true
                    break
                } else if eventsInDay[i].startInstant == event.startInstant {
                    // case 2
                    if eventsInDay[i].endInstant < event.endInstant {
                        eventsInDay.insert(event, at: i)
                        eventInserted = true
                        break
                    } else if eventsInDay[i].endInstant == event.endInstant {
                        //case 3
                        if eventsInDay[i].eventId > event.eventId {
                            eventsInDay.insert(event, at: i)
                            eventInserted = true
                            break
                        }
                    }
                }
            }
            if !eventInserted {
                eventsInDay.append(event)
            }
            eventsByDay[day]! = eventsInDay
            refreshDayView(day: day)
        }

    }
    func registerCalendarDayView(day: Int, dayView: CalendarDayView) {
        calendarDayViews[day] = dayView
    }
    
    
    static func getDayFromInstant(instant: Double) -> Double {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date(timeIntervalSince1970: instant))!.timeIntervalSince1970 //clears time components and returns the day in epoch-seconds
    }
    static func getDaysInRange(startDay: Double , endDay: Double) throws -> [Double]  {
        //startDay and endDay are included in result set
        if endDay < startDay {
            throw NSError()
        }
        if endDay == startDay {
            return [startDay]
        }
        var curr_day = Date(timeIntervalSince1970: startDay)
        var days: [Double] = []
        while curr_day.timeIntervalSince1970 < endDay {
            days.append(curr_day.timeIntervalSince1970)
            //get next_day
            var date_components = DateComponents()
            date_components.day = 1
            let new_day = Calendar.current.date(byAdding: date_components, to: curr_day)
            curr_day = new_day!
        }
        return days
    }
    
    func refreshDayView(day: Int) {
        calendarDayViews[day]?.calculateEventRects()
    }
}
