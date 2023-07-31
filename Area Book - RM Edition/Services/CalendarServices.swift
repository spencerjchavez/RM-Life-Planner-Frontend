//
//  CalendarServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct CalendarServices {
    static var authentication: Authentication?
    
    
    static func createEvent(event: CalendarEvent) async -> Int{
        if authentication == nil { return -1 /* TODO: throw error */}
        
    }
    static func deleteEvent(eventId: Int) async {
        
    }
    static func updateEvent(eventId: Int, event: CalendarEvent) async {
        
    }
    static func getEvent(eventId: Int) async -> CalendarEvent {
        
    }
    static func getEvents(days: [Double]) async -> [Int: [CalendarEvent]] {
        //TODO: call api endpoint for get days
        var events: [Int: [CalendarEvent]] = [:]
        for (day, eventList) in events {
            events[day] = sortEventList(events: eventList)
        }
        return events
    }
    static func getEvents(startDay: Double, endDay: Double? = nil) async -> [Int: [CalendarEvent]] {
        // return events by:
        // 1. increasing startInstant
        // 2. decreasing endInstant
        // 3. increasing eventId
        
        //set endDay to 1 day later if null
        var endDay = endDay
        if endDay == nil {
            let dc = DateComponents(day:1)
            endDay = Calendar.current.date(byAdding: dc, to: Date(timeIntervalSince1970: startDay))!.timeIntervalSince1970
        }
        
        //TODO: call api endpoint for get days
        var events: [Int: [CalendarEvent]] = [:]
        
        //sort the list of events
        for (day, eventList) in events {
            events[day] = sortEventList(events: eventList)
        }
        return events
    }
    private static func sortEventList(events: [CalendarEvent]) -> [CalendarEvent] {
        var eventList = events
        eventList.sort { a, b in
            if a.startInstant < b.startInstant { return true}
            if b.startInstant < a.startInstant { return false}
            if a.endInstant > b.endInstant { return true}
            if b.endInstant > a.endInstant { return false}
            if a.eventId < b.eventId { return true}
            return false
        }
        return eventList
    }
}
