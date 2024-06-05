//
//  CalendarEventsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class CalendarEventsManager : ObservableObject {
    /*
     All functions in this class must update eventIdsByDate BEFORE updating eventsById. Otherwise, publisher will not publish changes to eventIdsByDate properly.
     */
    
    @Published var eventsById: [Int: CalendarEventLM] = [:]
    @Published var eventIdsByDate: [Date: [Int]] = [:]
    var eventIdsByGoalId: [Int: [Int]] = [:]
    var managerTaskScheduler = ManagerTaskScheduler()
    var authentication: Authentication? = nil
    
    func createCalendarEvent(event: CalendarEventLM) {
        let FUNC_NAME = "CalendarEventManager.createCalendarEvent(event)"
        guard eventsById[event.eventId] == nil else {
            ErrorManager.reportError(throwingFunction:  FUNC_NAME, loggingMessage: "Invalid state! Attempted to create event with id \(event.eventId), but event of that id already exists", messageToUser: "Error encountered while adding event, please try again later.")
            return
        }
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        eventsById[event.eventId] = event
        addToCalendarEventIdsByDate(event)
        addToCalendarEventIdsByGoalId(event)
        managerTaskScheduler.schedule(syncId: event.eventId) {
            do {
                let eventSM = CalendarEventSM(from: event)
                let serverSideId = try await CalendarEventServices.create(eventSM, authentication: authentication)
                DispatchSerialQueue.main.async {
                    IdsManager.associateServerId(serverSideId: serverSideId, with: event.eventId, modelType: CalendarEventLM.getModelName())
                }
            } catch RMLifePlannerError.serverError(let message){
                DispatchSerialQueue.main.async {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \"\(message)\" while adding eventId \(event.eventId)", messageToUser: "Error encountered while adding event, please try again later.")
                    self.eventsById[event.eventId] = nil
                    self.removeFromCalendarEventIdsByDate(event)
                    self.removeFromCalendarEventIdsByGoalId(event)
                }
            } catch {
                DispatchSerialQueue.main.async {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating event", messageToUser: "Error encountered while adding event, please try again later.")
                    self.eventsById[event.eventId] = nil
                    self.removeFromCalendarEventIdsByDate(event)
                    self.removeFromCalendarEventIdsByGoalId(event)
                }
            }
        }
    }
    
    func getCalendarEvent(eventId: Int) -> CalendarEventLM? {
        let FUNC_NAME = "CalendarEventsManager.getCalendarEvent(eventId)"
        if let event = eventsById[eventId] {
            return event
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Failed to get event with id: \(eventId)", messageToUser: "Error encountered while getting event, please try again later.")
        }
        return nil
    }
    
    func getLocalCalendarEventsOnDate(_ date: Date, userRequested: Bool = false) -> [CalendarEventLM] {
        return getLocalCalendarEventsInRange(date, date)
    }
    
    func getLocalCalendarEventsInRange(_ startDate: Date, _ endDate: Date, userRequested: Bool = false) -> [CalendarEventLM] {
        let FUNC_NAME = "CalendarEventsManager.getLocalCalendarEventsInRange(startDate, endDate)"
        do {
            let dates = try DateHelper.getDatesInRange(startDate: startDate, endDate: endDate)
            let eventsDict = getLocalCalendarEventsOnDates(dates)
            var eventsSet = Set<CalendarEventLM>()
            for eventList in eventsDict.values {
                for event in eventList {
                    eventsSet.insert(event)
                }
            }
            return Array(eventsSet)
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to retrieve in dates of invalid range \(startDate) to \(endDate)", messageToUser: "Error encountered. Please try again")
        }
        return []
    }
    
    func getLocalCalendarEventsOnDates(_ dates: [Date], userRequested: Bool = false) -> [Date: [CalendarEventLM]] {
        let FUNC_NAME = "CalendarEventsManager.getLocalCalendarEventsOnDates(dates)"
        var toReturn: [Date: [CalendarEventLM]] = [:]
        var datesToFetchFromServer: [Date] = []
        for date in dates {
            toReturn[date] = []
            if let eventIds = eventIdsByDate[date] {
                for eventId in eventIds {
                    if let event = eventsById[eventId] {
                        toReturn[date]!.append(event)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state. Event id found in eventIdsByDay but does not exist in eventsById", messageToUser: "Error encountered please restart or try again later")
                    }
                }
            } else {
                // add date to list to fetch from server async
                datesToFetchFromServer.append(date)
                self.eventIdsByDate[date] = []
            }
        }
        if datesToFetchFromServer.isEmpty {
            return toReturn
        }
        let datesToFetch = datesToFetchFromServer
        Task {
            let _ = await getCalendarEventsOnDates(datesToFetch)
        }
        return toReturn
    }
    
    func getCalendarEventsInRange(_ startDate: Date, _ endDate: Date) async -> [CalendarEventLM] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsInRange(startDate endDate)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return []
        }
        do{
            let eventSMs = try await CalendarEventServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), SQLDateFormatter.toSQLDateString(endDate), authentication: authentication)
            var toReturn: [CalendarEventLM] = []
            for eventSM in eventSMs {
                let eventLM = try CalendarEventLM(from: eventSM)
                toReturn.append(eventLM)
            }
            let events = toReturn
            DispatchSerialQueue.main.async {
                for eventLM in events {
                    self.eventsById[eventLM.eventId] = eventLM
                    self.addToCalendarEventIdsByDate(eventLM)
                    self.addToCalendarEventIdsByGoalId(eventLM)
                }
            }
            return toReturn
            
        } catch RMLifePlannerError.serverError(let message) {
            DispatchSerialQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
            }
        } catch let err {
            DispatchSerialQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
            }
        }
        return []
    }
    
    func getCalendarEventsOnDates(_ dates: [Date]) async -> [Date: [CalendarEventLM]] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsOnDates(dates)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return [:]
        }
        let dateStrings = dates.map({ date in
            SQLDateFormatter.toSQLDateString(date)
        })
        var eventsSMByDate: [String: [CalendarEventSM]] = [:]
        do {
            eventsSMByDate = try await CalendarEventServices.getByDates(dateStrings, authentication: authentication)
        } catch RMLifePlannerError.serverError(let message) {
            DispatchSerialQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
            }
        } catch let err {
            DispatchSerialQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
            }
        }
        let eventSMsByDate = eventsSMByDate
        return DispatchQueue.main.sync {
            for dateString in dateStrings {
                if let date = SQLDateFormatter.toDate(ymdDate: dateString) {
                    self.eventIdsByDate[date] = []
                    do {
                        if let eventSms = eventSMsByDate[dateString] {
                            for eventSm in eventSms {
                                let eventLM = try CalendarEventLM(from: eventSm)
                                self.eventsById[eventLM.eventId] = eventLM
                                self.eventIdsByDate[date]?.append(eventLM.eventId)
                                self.addToCalendarEventIdsByGoalId(eventLM)
                            }
                        } else {
                            throw RMLifePlannerError.serverError("couldn't parse string")
                        }
                    } catch let err {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not parse date string from database: \(dateString)", messageToUser: "Error retrieving events, please try again later")
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not parse date string from database: \(dateString)", messageToUser: "Error retrieving events, please try again later")
                }
            }
            var eventsByDate: [Date: [CalendarEventLM]] = [:]
            for date in dates {
                eventsByDate[date] = self.eventIdsByDate[date]?.compactMap({ eventId in
                    if let event = self.eventsById[eventId] {
                        return event
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, event id found in eventIdsByDate but does not exist in eventsById", messageToUser: "Error encountered, please restart or try again later")
                        return nil
                    }
                })
            }
            return eventsByDate
        }
    }

    
    func getCalendarEventsByGoalIds(_ goalIds: [Int]) async -> [Int: [CalendarEventLM]] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsByGoalIds(goalIds)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return [:]
        }
        let serverGoalIds = DispatchQueue.main.sync {
            do {
                let serverGoalIds = try goalIds.map({ goalId in
                    guard let serverId = IdsManager.getServerId(from: goalId) else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "goal of id: \(goalId) did not have an associated server goal id", messageToUser: "error retrieving events, please try again later")
                        throw RMLifePlannerError.clientError
                    }
                    return serverId
                })
                return serverGoalIds
            } catch RMLifePlannerError.serverError(let message) {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
            } catch let err {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
            }
            return []
        }
        do {
            var toReturn: [Int: [CalendarEventLM]] = [:]
            let eventSMsByGoal = try await CalendarEventServices.getByGoalIds(serverGoalIds, authentication: authentication)
            try DispatchQueue.main.sync {
                for goalId in eventSMsByGoal.keys {
                    let localGoalId = try IdsManager.getOrGenerateLocalId(from: goalId, modelType: CalendarEventLM.getModelName())
                    toReturn[localGoalId] = try eventSMsByGoal[goalId]?.map({ eventSm in
                        return try CalendarEventLM(from: eventSm)
                    })
                }
            }
            return toReturn
        } catch let err {
            DispatchQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
            }
        }
        return [:]
    }

    func getLocalCalendarEventsByGoalIds(_ goalIds: [Int]) -> [Int: [CalendarEventLM]] {
        var toReturn: [Int: [CalendarEventLM]] = [:]
        var toFetch: [Int] = []
        for goalId in goalIds {
            if let eventIds = self.eventIdsByGoalId[goalId] {
                let events = eventIds.compactMap({ eventId in
                    return self.eventsById[eventId]
                })
                toReturn[goalId] = events
            } else {
                toFetch.append(goalId)
                // this prevents fetching from server multiple times
                self.eventIdsByGoalId[goalId] = []
            }
        }
        let goalIdsToFetch = toFetch
        Task {
            let _ = await getCalendarEventsByGoalIds(goalIdsToFetch)
        }
        return toReturn
    }
    
    func updateCalendarEvent(eventId: Int, updatedCalendarEvent: CalendarEventLM) {
        let FUNC_NAME = "CalendarEventsManager.updateCalendarEvent(eventId, updatedCalendarEvent)"
        guard eventId == updatedCalendarEvent.eventId else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, updated event has different id than original event", messageToUser: "Error encountered. Please try again later.")
            return
        }
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldCalendarEvent = eventsById[eventId] {
            removeFromCalendarEventIdsByDate(oldCalendarEvent)
            removeFromCalendarEventIdsByGoalId(oldCalendarEvent)
            addToCalendarEventIdsByDate(updatedCalendarEvent)
            addToCalendarEventIdsByGoalId(updatedCalendarEvent)
            eventsById[eventId] = updatedCalendarEvent
            // update eventsById last, so that changes to eventsByDay are captured
            // when dragging and dropping to a new day

            managerTaskScheduler.schedule(syncId: eventId) {
                var updatedCalendarEventVar = updatedCalendarEvent
                updatedCalendarEventVar.eventId = eventId
                let updatedCalendarEvent = updatedCalendarEventVar
                do{
                    let updatedCalendarEventSM = CalendarEventSM(from: updatedCalendarEvent)
                    if let serverSideId = updatedCalendarEventSM.eventId {
                        try await CalendarEventServices.update(serverSideId, updatedCalendarEventSM, authentication: authentication)
                    } else {
                        DispatchQueue.main.async {
                            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(eventId)", messageToUser: "Error encountered while updating event, please try again later or restart the app.")
                            self.eventsById[eventId] = nil
                            self.removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                            self.removeFromCalendarEventIdsByGoalId(updatedCalendarEvent)
                        }
                    }
                } catch RMLifePlannerError.clientError {
                    DispatchQueue.main.async {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create CalendarEventSM from CalendarEventLM of id \(updatedCalendarEvent.eventId)", messageToUser: "Error encountered while updating event, please try again later.")
                        self.eventsById[eventId] = oldCalendarEvent
                        self.removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                        self.removeFromCalendarEventIdsByGoalId(updatedCalendarEvent)
                        self.addToCalendarEventIdsByDate(oldCalendarEvent)
                        self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                    }
                } catch RMLifePlannerError.serverError(let message){
                    DispatchQueue.main.async {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating event of id \(eventId)", messageToUser: "Error encountered while updating event, please try again later.")
                        self.eventsById[eventId] = oldCalendarEvent
                        self.removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                        self.removeFromCalendarEventIdsByGoalId(updatedCalendarEvent)
                        self.addToCalendarEventIdsByDate(oldCalendarEvent)
                        self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                    }
                } catch {
                    DispatchQueue.main.async {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating event", messageToUser: "Error encountered while updating event, please try again later.")
                        self.eventsById[eventId] = oldCalendarEvent
                        self.removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                        self.removeFromCalendarEventIdsByGoalId(updatedCalendarEvent)
                        self.addToCalendarEventIdsByDate(oldCalendarEvent)
                        self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a event of id: \(eventId)", messageToUser: "Error encountered while updating event, please try again later or restart the app.")
            }
        }
    }
    
    func deleteCalendarEvent(eventId: Int) {
        let FUNC_NAME = "CalendarEventsManager.deleteCalendarEvent(eventId)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldCalendarEvent = eventsById[eventId] {
            removeFromCalendarEventIdsByDate(oldCalendarEvent)
            removeFromCalendarEventIdsByGoalId(oldCalendarEvent)
            eventsById[eventId] = nil
            managerTaskScheduler.schedule(syncId: eventId) {
                do {
                    let serverSideId = try DispatchQueue.main.sync {
                        guard let serverSideId = IdsManager.getServerId(from: eventId) else {
                            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(eventId)", messageToUser: "Error encountered while deleting event, please try again later or restart the app.")
                            self.eventsById[eventId] = oldCalendarEvent
                            self.addToCalendarEventIdsByDate(oldCalendarEvent)
                            self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                            throw RMLifePlannerError.clientError
                        }
                        return serverSideId
                    }
                    try await CalendarEventServices.delete(serverSideId, authentication: authentication)
                } catch RMLifePlannerError.serverError(let message){
                    DispatchQueue.main.async {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting event of id \(eventId)", messageToUser: "Error encountered while deleting event, please try again later.")
                        self.eventsById[eventId] = oldCalendarEvent
                        self.addToCalendarEventIdsByDate(oldCalendarEvent)
                        self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                    }
                } catch {
                    DispatchQueue.main.async {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting event", messageToUser: "Error encountered while deleting event, please try again later.")
                        self.eventsById[eventId] = oldCalendarEvent
                        self.addToCalendarEventIdsByDate(oldCalendarEvent)
                        self.addToCalendarEventIdsByGoalId(oldCalendarEvent)
                    }
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a event with id: \(eventId)", messageToUser: "Error encountered while deleting event, please try again later or restart the app.")
        }
    }
    func deleteEventsWithLinkedTodoId(_ todoId: Int) {
        let eventsToDelete = eventsById.values.filter({ event in
            event.linkedTodoId == todoId
        })
        for event in eventsToDelete {
            eventsById.removeValue(forKey: event.eventId)
            removeFromCalendarEventIdsByDate(event)
            removeFromCalendarEventIdsByGoalId(event)
        }
    }
    func invalidateEventsAfterDate(after: Date) {
        do {
            var datesToFetch: [Date] = []
            let eventsToInvalidate = try eventsById.values.filter({ event in
                if event.endInstant >= after {
                    datesToFetch.append(
                        contentsOf: try DateHelper.getDatesInRange(startDate: event.startInstant, endDate: event.endInstant).filter({ date in
                            return date >= after
                        }))
                    return true
                }
                return false
            })
            for event in eventsToInvalidate {
                eventsById[event.eventId] = nil
                removeFromCalendarEventIdsByDate(event)
                removeFromCalendarEventIdsByGoalId(event)
            }
            Task {
                _ = await getCalendarEventsOnDates([after])
            }
        } catch let error {
            ErrorManager.reportError(throwingFunction: "CalendarEventsManager.invalidateEventsAfterDate(after)", loggingMessage: "\(error)", messageToUser: "Error encountered! Please try again later")
        }
    }
    private func addToCalendarEventIdsByDate(_ event: CalendarEventLM) {
        let range = try! DateHelper.getDatesInRange(startDate: event.startInstant, endDate: event.endInstant)
        for date in range {
            if var eventIds = eventIdsByDate[date] {
                eventIds.append(event.eventId)
                eventIdsByDate[date] = eventIds
            } else {
                eventIdsByDate[date] = [event.eventId]
            }
        }
    }
    
    private func removeFromCalendarEventIdsByDate(_ event: CalendarEventLM) {
        for date in eventIdsByDate.keys {
            if try! date >= DateHelper.getDateAtMidnight(event.startInstant) {
                if try! date <= DateHelper.getDateAtMidnight(event.endInstant) {
                    eventIdsByDate[date]?.removeAll(where: { eventId in
                        eventId == event.eventId
                    })
                }
            }
        }
    }
    
    private func addToCalendarEventIdsByGoalId(_ event: CalendarEventLM) {
        if let linkedGoalId = event.linkedGoalId {
            var eventIds = eventIdsByGoalId[linkedGoalId] ?? []
            eventIds.append(event.eventId)
            eventIdsByGoalId[linkedGoalId] = eventIds
        }
    }
    private func removeFromCalendarEventIdsByGoalId(_ event: CalendarEventLM) {
        if let linkedGoalId = event.linkedGoalId {
            var eventIds = self.eventIdsByGoalId[linkedGoalId] ?? []
            eventIds.removeAll(where: { eventId in
                eventId == event.eventId
            })
            self.eventIdsByGoalId[linkedGoalId] = eventIds
        }
    }
}
