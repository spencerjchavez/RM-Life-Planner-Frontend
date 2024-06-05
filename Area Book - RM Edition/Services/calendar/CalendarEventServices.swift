//
//  CalendarServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct CalendarEventServices {
    static let url = GlobalVars.CALENDAR_EVENTS_URL
    static let timeout = GlobalVars.TIMEOUT_INTERVAL

    static func create(_ event: CalendarEventSM, authentication: Authentication) async throws -> Int {
        let data = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateEventReqBody(event, authentication: authentication))
        if let json = try? JSONDecoder().decode([String: Int].self, from: data) {
            if let eventId = json["event_id"] {
                return eventId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse eventId from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse server response")
        }
    }
    static func delete(_ eventId: Int, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(eventId)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    static func update(_ eventId: Int, _ event: CalendarEventSM, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(eventId)"), httpMethod: "PUT", httpBodyToEncode: UpdateEventReqBody(event, authentication: authentication))
    }
    static func getById(_ eventId: Int, authentication: Authentication) async throws -> CalendarEventSM {
        let data = try await JSONRetriever.getJson(
            url: GlobalVars.GET_CALENDAR_EVENT_BY_ID_URL.appending(path: "/\(eventId)"),
            httpMethod: "GET",
            queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: CalendarEventSM].self, from: data) {
            if let event = json["event"] {
                return event
            } else {
                throw RMLifePlannerError.serverError("couldn't parse 'event' key from json dict: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse event from json data: \(data)")
        }
    }
    static func getByDates(_ dates: [String], authentication: Authentication) async throws -> [String: [CalendarEventSM]] {
        if dates.isEmpty {
            return [:]
        }
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_CALENDAR_EVENTS_IN_DATE_LIST_URL,
                                                    httpMethod: "POST",
                                                    httpBodyToEncode: dates,
                                                    queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [String: [CalendarEventSM]]].self, from: data) {
            if let events = json["events"] {
                return events
            } else {
                throw RMLifePlannerError.serverError("could not parse events from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("could not parse json response: \(data)")
        }
    }
    
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil, authentication: Authentication) async throws -> [CalendarEventSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate),
         URLQueryItem(name: "end_date", value: endDate ?? startDate)]
        queryItems.append(contentsOf: authentication.authQueryItems())
                                                            
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_CALENDAR_EVENTS_IN_DATE_LIST_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let json = try? JSONDecoder().decode([String: [CalendarEventSM]].self, from: data) {
            if let events = json["events"] {
                return events
            } else {
                throw RMLifePlannerError.serverError("couldn't parse events from data: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse events from data: \(data)")
        }
    }
    
    static func getByGoalIds(_ goalIds: [Int], authentication: Authentication) async throws -> [Int: [CalendarEventSM]] {
        if goalIds.isEmpty {
            return [:]
        }
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_CALENDAR_EVENTS_BY_GOAL_ID_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: goalIds,
                                                   queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [Int: [CalendarEventSM]]].self, from: data) {
            if let eventsByGoalId = json["events"] {
                return eventsByGoalId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse events from data: \(data)")
        }
    }
    /*private static func sortEventList(events: [CalendarEventSM]) -> [CalendarEventSM] {
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
    } */
}
struct CreateEventReqBody : Codable {
    var event: CalendarEventSM
    var authentication: Authentication
    
    init(_ event: CalendarEventSM, authentication: Authentication) {
        self.event = event
        self.authentication = authentication
    }
}
struct UpdateEventReqBody : Codable {
    var updated_event: CalendarEventSM
    var authentication: Authentication
    
    init(_ updated_event: CalendarEventSM, authentication: Authentication) {
        self.updated_event = updated_event
        self.authentication = authentication
    }
}
