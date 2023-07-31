//
//  CalendarEventsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/24/23.
//

import Foundation

class CalendarEventsManager : ObservableObject{
    @Published var eventIdsByDay: [Int: [Int]] = [:]
    @Published var eventsById: [Int: CalendarEvent] = [:]
    var idCollection: IDCollection = IDCollection()
    var activeTasksByEventId: [Int: Task<Int, Never>]
    var eventIdToDrop = -1
    
    func getEventsOnDay(day: Double, userRequested: Bool = false) async throws -> [CalendarEvent] {
        do {
            let dayInt = Int(day)
            var toReturn: [CalendarEvent] = []
            if eventIdsByDay[dayInt] == nil {
                eventIdsByDay[dayInt] = []
                var events = await CalendarServices.getEvents(startDay: day)[dayInt]!
                for var event in events {
                    let eventId = try idCollection.getOrGenerateClientSideId(from: event.eventId!)
                    event.eventId = eventId
                    eventsById[eventId] = event
                    eventIdsByDay[dayInt]!.append(eventId)
                    toReturn.append(event)
                }
            } else {
                for id in eventIdsByDay[dayInt]! {
                    if let event = eventsById[id] {
                        toReturn.append(event)
                    }
                }
            }
            if userRequested {
                await userAccessedDay(day: dayInt)
            }
            return toReturn
        }
    }
    func getEventsOnDays(startDay: Double, endDay: Double, userRequested: Bool = false) async throws -> [Int: [CalendarEvent]] {
        let daysRange = try! CalendarEventsManager.getDaysInRange(startInstant: startDay, endInstant: endDay)
        var daysToReturn: [Int:[CalendarEvent]] = [:]
        var daysToFetch: [Double] = []
        for day in daysRange {
            if eventsByDay[Int(day)] == nil {
                daysToFetch.append(day)
            } else {
                daysToReturn[Int(day)] = eventsByDay[Int(day)]
            }
        }
        let eventsFetched = await CalendarServices.getEvents(days: daysToFetch)
        for day in eventsFetched.keys {
            eventsByDay[day] = eventsFetched[day]
            for event in eventsFetched[day] ?? [] {
                let clientSideId = idCollection.getOrGenerateClientSideId(from: event.eventId)
                event.eventId = clientSideId
                eventsById[clientSideId] = event
            }
            daysToReturn[day] = eventsFetched[day]
        }
        //  TODO: CALL USERACCESSEDDAYS()
        return daysToReturn
    }
    func getEventById(eventId: Int, userRequested: Bool = false) async -> CalendarEvent {
        if eventsById[eventId] == nil {
            if let serverSideId = idCollection.getServerSideId(from: eventId) {
                eventsById[eventId] = await CalendarServices.getEvent(eventId: serverSideId)
            }
        }
        if userRequested {
            await userAccessedDay(day: Int(CalendarEventsManager.getDayFromInstant(instant: eventsById[eventId]!.startInstant)))
        }
        return eventsById[eventId]!
    }
    func updateEventData(eventId: Int, updatedEvent: CalendarEvent) throws {
        let event = await getEventById(eventId: eventId)
        if let serverSideId = idCollection.getServerSideId(from: eventId) {
            await CalendarServices.updateEvent(eventId: eventId, event: updatedEvent)
            eventsById[eventId] = updatedEvent
            if event.startInstant != updatedEvent.startInstant
                || event.endInstant != updatedEvent.endInstant {
                // update eventsByDay, as event times have been changed
                let oldDayRange = try CalendarEventsManager.getDaysInRange(startInstant: event.startInstant, endInstant: event.endInstant)
                //update eventsByDay
                for day in oldDayRange {
                    let day = Int(day)
                    eventIdsByDay[day]?.removeAll(where: {id in
                        id == eventId
                    })
                }
                try! addToEventsByDay(event: updatedEvent)
            }
        } else { throw RMLifePlannerError.unexpectedClientSideError }
    }
    
    func addEvent(event: CalendarEvent) throws -> Int {
        let clientSideId = try idCollection.generateId()
        activeTasksByEventId[clientSideId] = Task { () -> Int in
            let serverSideId = await CalendarServices.createEvent(event: event)
            idCollection.associateServerSideId(serverSideId: serverSideId, with: clientSideId)
            return serverSideId
        }
        var event = event
        event.eventId = clientSideId
        eventsById[event.eventId!] = event
        try addToEventsByDay(event: event)
        return event.eventId!
    }
    
    private func addToEventsByDay(event: CalendarEvent, userRequested: Bool = false) throws {
        let days = try CalendarEventsManager.getDaysInRange(startInstant: event.startInstant, endInstant: event.endInstant)
        for day in days {
            let dayInt = Int(day)
            if eventsByDay[dayInt] == nil {
                eventsByDay[dayInt] = await CalendarServices.getEvents(startDay: day)[dayInt]
            }
            eventsByDay[dayInt]! = insertIntoEventsInDay(eventsInDay: eventsByDay[dayInt]!, event: event)
            if userRequested {
               await userAccessedDay(day: Int(day))
            }
        }
    }
    func deleteEvent(eventId: Int, userRequested: Bool = false) async {
        await removeFromEventsByDay(eventId: eventId, userRequested: userRequested)
        await CalendarServices.deleteEvent(eventId: eventId)
        eventsById[eventId] = nil
    }
    
    private func userAccessedDay(day: Int) async {
        let dayDate = Date(timeIntervalSince1970: TimeInterval(day))
        let prevDayDC = DateComponents(day:-1)
        let prevDay = Calendar.current.date(byAdding: prevDayDC, to: dayDate)!.timeIntervalSince1970
        let nextDayDC = DateComponents(day:1)
        let nextDay = Calendar.current.date(byAdding: nextDayDC, to: dayDate)!.timeIntervalSince1970
        if eventsByDay[Int(prevDay)] == nil || eventsByDay[Int(nextDay)] == nil {
            // get events from the server before we need them
            let subDC = DateComponents(day: -7)
            let addDC = DateComponents(day: 7)
            let startDay = Calendar.current.date(byAdding: subDC, to: dayDate)!.timeIntervalSince1970
            let endDay = Calendar.current.date(byAdding: addDC, to: dayDate)!.timeIntervalSince1970
            try! await getEventsOnDays(startDay: startDay, endDay: endDay, userRequested: false)
        }
    }
    
    // eventId must not yet be deleted
    private func removeFromEventsByDay(eventId: Int, userRequested: Bool = false) async {
        let event = await getEventById(eventId: eventId)
        let days = try! CalendarEventsManager.getDaysInRange(startInstant: event.startInstant, endInstant: event.endInstant)
        for day in days {
            eventsByDay[Int(day)] = nil
            if userRequested {
                await userAccessedDay(day: Int(day))
            }
        }
    }
    private func insertIntoEventsInDay(eventsInDay: [CalendarEvent], event: CalendarEvent) -> [CalendarEvent] {
        // order events by:
        // 1. increasing startInstant
        // 2. decreasing endInstant
        // 3. increasing eventId
        
        var eventsInDay = eventsInDay
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
        return eventsInDay
        
    }
    
    static func getDayFromInstant(instant: Double) -> Double {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date(timeIntervalSince1970: instant))!.timeIntervalSince1970 //clears time components and returns the day in epoch-seconds
    }
    static func getDaysInRange(startInstant: Double , endInstant: Double) throws -> [Double]  {
        let startDay = getDayFromInstant(instant: startInstant)
        let endDay = getDayFromInstant(instant: endInstant)
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
}
