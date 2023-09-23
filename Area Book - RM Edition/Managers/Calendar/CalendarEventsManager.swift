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
    static var activeTasksByCalendarEventId: [Int: Task<Void, Never>] = [:]
    static var activeTasksByDate: [Date: Task<Void, Never>] = [:]

    
    func createCalendarEvent(event: CalendarEventLM) {
        let FUNC_NAME = "CalendarEventManager.createCalendarEvent(event)"
        guard eventsById[event.eventId] == nil else {
            ErrorManager.reportError(throwingFunction:  FUNC_NAME, loggingMessage: "Invalid state! Attempted to create event with id \(event.eventId), but event of that id already exists", messageToUser: "Error encountered while adding event, please try again later.")
            return
        }
        eventsById[event.eventId] = event
        addToCalendarEventIdsByDate(event)
        var toAwait: Task<Void, Never>? // must await creation of linked goal first
        if let linkedGoalId = event.linkedGoalId {
            toAwait = GoalsManager.activeTasksByGoalId[linkedGoalId]
        }
        let goalToAwait = toAwait
        if let linkedTodoId = event.linkedTodoId {
            toAwait = TodosManager.activeTasksByTodoId[linkedTodoId]
        }
        let todoToAwait = toAwait
        CalendarEventsManager.activeTasksByCalendarEventId[event.eventId] = Task {
            do {
                await goalToAwait?.value
                await todoToAwait?.value
                let eventSM = CalendarEventSM(from: event)
                let serverSideId = try await CalendarEventServices.create(eventSM)
                IdsManager.associateServerId(serverSideId: serverSideId, with: event.eventId, modelType: CalendarEventLM.getModelName())
            } catch RMLifePlannerError.serverError(let message){
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while adding eventId \(event.eventId)", messageToUser: "Error encountered while adding event, please try again later.")
                eventsById[event.eventId] = nil
                removeFromCalendarEventIdsByDate(event)
            } catch {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating event", messageToUser: "Error encountered while adding event, please try again later.")
                eventsById[event.eventId] = nil
                removeFromCalendarEventIdsByDate(event)
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
            }
        }
        if datesToFetchFromServer.isEmpty {
            return toReturn
        }
        var tasksToAwait: [Task <Void, Never>] = []
        for date in datesToFetchFromServer {
            if let task = CalendarEventsManager.activeTasksByDate[date] {
                tasksToAwait.append(task)
            }
        }
        let toAwait = tasksToAwait
        let datesToFetch = datesToFetchFromServer
        let task = Task {
            for task in toAwait {
                await task.value
            }
            let events = await getCalendarEventsOnDates(datesToFetch)
        }
        for date in datesToFetch {
            CalendarEventsManager.activeTasksByDate[date] = task
        }
        return toReturn
    }
    
    func getCalendarEventsInRange(_ startDate: Date, _ endDate: Date) async -> [CalendarEventLM] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsInRange(startDate endDate)"
        do{
            let eventSMs = try await CalendarEventServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), SQLDateFormatter.toSQLDateString(endDate))
            var toReturn: [CalendarEventLM] = []
            for eventSM in eventSMs {
                let eventLM = try CalendarEventLM(from: eventSM)
                eventsById[eventLM.eventId] = eventLM
                addToCalendarEventIdsByDate(eventLM)
                toReturn.append(eventLM)
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message) {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
        }
        return []
    }
    
    func getCalendarEventsOnDates(_ dates: [Date]) async -> [Date: [CalendarEventLM]] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsOnDates(dates)"
        do {
            let dateStrings = dates.map({ date in
                SQLDateFormatter.toSQLDateString(date)
            })
            let eventsSMByDate = try await CalendarEventServices.getByDates(dateStrings)
            for dateString in dateStrings {
                if let date = SQLDateFormatter.toDate(ymdDate: dateString) {
                    eventIdsByDate[date] = []
                    if let eventSms = eventsSMByDate[dateString] {
                        for eventSm in eventSms {
                            let eventLM = try CalendarEventLM(from: eventSm)
                            eventsById[eventLM.eventId] = eventLM
                            eventIdsByDate[date]?.append(eventLM.eventId)
                        }
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not parse date string from database: \(dateString)", messageToUser: "Error retrieving events, please try again later")
                }
            }
            var eventsByDate: [Date: [CalendarEventLM]] = [:]
            for date in dates {
                eventsByDate[date] = eventIdsByDate[date]?.compactMap({ eventId in
                    if let event = eventsById[eventId] {
                        return event
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, event id found in eventIdsByDate but does not exist in eventsById", messageToUser: "Error encountered, please restart or try again later")
                        return nil
                    }
                })
            }
            return eventsByDate
        } catch RMLifePlannerError.serverError(let message) {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
        }
        return [:]
    }
    
    func getCalendarEventsByGoalIds(_ goalIds: [Int]) async -> [Int: [CalendarEventLM]] {
        let FUNC_NAME = "CalendarEventManager.getCalendarEventsByGoalIds(goalIds)"
        do {
            var toReturn: [Int: [CalendarEventLM]] = [:]
            let serverGoalIds = try goalIds.map({ goalId in
                guard let serverId = IdsManager.getServerId(from: goalId) else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "goal of id: \(goalId) did not have an associated server goal id", messageToUser: "error retrieving events, please try again later")
                    throw RMLifePlannerError.clientError
                }
                return serverId
            })
            let eventSMsByGoal = try await CalendarEventServices.getByGoalIds(serverGoalIds)
            for goalId in eventSMsByGoal.keys {
                let localGoalId = try IdsManager.getOrGenerateLocalId(from: goalId, modelType: CalendarEventLM.getModelName())
                toReturn[localGoalId] = try eventSMsByGoal[goalId]?.map({ eventSm in
                    return try CalendarEventLM(from: eventSm)
                })
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message) {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Received server error: \(message)", messageToUser: "Error encountered. Please try again")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error encountered: \(err)", messageToUser: "Error encountered. Please try again")
        }
        return [:]
    }
    
    func updateCalendarEvent(eventId: Int, updatedCalendarEvent: CalendarEventLM) {
        let FUNC_NAME = "CalendarEventsManager.updateCalendarEvent(eventId, updatedCalendarEvent)"
        let taskToAwait = CalendarEventsManager.activeTasksByCalendarEventId[eventId]
        if let oldCalendarEvent = eventsById[eventId] {
            if oldCalendarEvent.startInstant != updatedCalendarEvent.startInstant || oldCalendarEvent.endInstant != updatedCalendarEvent.endInstant {
                // need to change eventIDsByDate
                removeFromCalendarEventIdsByDate(oldCalendarEvent)
                addToCalendarEventIdsByDate(updatedCalendarEvent)
            }
            eventsById[eventId] = updatedCalendarEvent
            // update eventsById last, so that changes to eventsByDay are captured
            // when dragging and dropping to a new day

            var toAwait: Task<Void, Never>?
            if let linkedGoalId = updatedCalendarEvent.linkedGoalId {
                if oldCalendarEvent.linkedGoalId != linkedGoalId {
                    toAwait = GoalsManager.activeTasksByGoalId[linkedGoalId]
                }
            }
            let goalTaskToAwait = toAwait
            if let linkedTodoId = updatedCalendarEvent.linkedTodoId {
                if oldCalendarEvent.linkedTodoId != linkedTodoId {
                    toAwait = TodosManager.activeTasksByTodoId[linkedTodoId]
                }
            }
            let todoTaskToAwait = toAwait
            CalendarEventsManager.activeTasksByCalendarEventId[eventId] = Task {
                await taskToAwait?.value
                await goalTaskToAwait?.value
                await todoTaskToAwait?.value
                var updatedCalendarEvent = updatedCalendarEvent
                updatedCalendarEvent.eventId = eventId
                do{
                    let updatedCalendarEventSM = CalendarEventSM(from: updatedCalendarEvent)
                    if let serverSideId = updatedCalendarEventSM.eventId {
                        try await CalendarEventServices.update(serverSideId, updatedCalendarEventSM)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(eventId)", messageToUser: "Error encountered while updating event, please try again later or restart the app.")
                        eventsById[eventId] = nil
                        removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                    }
                } catch RMLifePlannerError.clientError {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create CalendarEventSM from CalendarEventLM of id \(updatedCalendarEvent.eventId)", messageToUser: "Error encountered while updating event, please try again later.")
                    eventsById[eventId] = oldCalendarEvent
                    removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                    addToCalendarEventIdsByDate(oldCalendarEvent)
                } catch RMLifePlannerError.serverError(let message){
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating event of id \(eventId)", messageToUser: "Error encountered while updating event, please try again later.")
                    eventsById[eventId] = oldCalendarEvent
                    removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                    addToCalendarEventIdsByDate(oldCalendarEvent)
                } catch {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating event", messageToUser: "Error encountered while updating event, please try again later.")
                    eventsById[eventId] = oldCalendarEvent
                    removeFromCalendarEventIdsByDate(updatedCalendarEvent)
                    addToCalendarEventIdsByDate(oldCalendarEvent)
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a event of id: \(eventId)", messageToUser: "Error encountered while updating event, please try again later or restart the app.")
        }
    }
    
    func deleteCalendarEvent(eventId: Int) {
        let FUNC_NAME = "CalendarEventsManager.deleteCalendarEvent(eventId)"
        if let oldCalendarEvent = eventsById[eventId] {
            removeFromCalendarEventIdsByDate(oldCalendarEvent)
            eventsById[eventId] = nil
            let taskToAwait = CalendarEventsManager.activeTasksByCalendarEventId[eventId]
            Task {
                await taskToAwait?.value
                if let serverSideId = IdsManager.getServerId(from: eventId) {
                    do {
                        try await CalendarEventServices.delete(serverSideId)
                    } catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting event of id \(eventId)", messageToUser: "Error encountered while deleting event, please try again later.")
                        //eventsById[eventId] = oldCalendarEvent
                        //addToCalendarEventIdsByDate(oldCalendarEvent)
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting event", messageToUser: "Error encountered while deleting event, please try again later.")
                       // eventsById[eventId] = oldCalendarEvent
                        //addToCalendarEventIdsByDate(oldCalendarEvent)
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(eventId)", messageToUser: "Error encountered while deleting event, please try again later or restart the app.")
                   // eventsById[eventId] = oldCalendarEvent
                    //addToCalendarEventIdsByDate(oldCalendarEvent)
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
}
