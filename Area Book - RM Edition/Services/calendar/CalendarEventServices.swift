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

    static func create(_ event: CalendarEventSM) async throws -> Int {
        let json = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateEventReqBody(event))
        if let eventId = json["event_id"] as? Int {
            return eventId
        } else {
            throw RMLifePlannerError.serverError("couldn't parse eventId from json: \(json)")
        }
    }
    static func delete(_ eventId: Int) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(eventId)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
    }
    static func update(_ eventId: Int, _ event: CalendarEventSM) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(eventId)"), httpMethod: "PUT", httpBodyToEncode: UpdateEventReqBody(event))
    }
    static func getById(_ eventId: Int) async throws -> CalendarEventSM {
        let json = try await JSONRetriever.getJson(
            url: GlobalVars.GET_CALENDAR_EVENT_BY_ID_URL.appending(path: "/\(eventId)"),
            httpMethod: "GET",
            queryItems: GlobalVars.authQueryItems)
        if let data = json["event"] as? Data {
            do {
                return try JSONDecoder().decode(CalendarEventSM.self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse event from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse event from json: \(json)")
        }
    }
    static func getByDates(_ dates: [String]) async throws -> [String: [CalendarEventSM]] {
        let json = try await JSONRetriever.getJson2(url: GlobalVars.GET_CALENDAR_EVENTS_IN_DATE_LIST_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: dates,
                                                   queryItems: GlobalVars.authQueryItems)
        do {
            if let events = try? JSONDecoder().decode([String: [String: [CalendarEventSM]]].self, from: json) {
                return events["events"] ?? [:]
            } else {
                return [:]
            }
        } catch {
            throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
        }
    }
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil) async throws -> [CalendarEventSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate),
         URLQueryItem(name: "end_date", value: endDate ?? startDate)]
        queryItems.append(contentsOf: GlobalVars.authQueryItems)
                                                            
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_CALENDAR_EVENTS_IN_DATE_LIST_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let data = json["events"] as? Data {
            do {
                return try JSONDecoder().decode([CalendarEventSM].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
        }
    }
    static func getByGoalIds(_ goalIds: [Int]) async throws -> [Int: [CalendarEventSM]] {
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_CALENDAR_EVENTS_BY_GOAL_ID_URL,
                                                   httpMethod: "GET",
                                                   httpBodyToEncode: goalIds,
                                                   queryItems: GlobalVars.authQueryItems)
        if let data = json["events"] as? Data {
            do {
                return try JSONDecoder().decode([Int: [CalendarEventSM]].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse events from json: \(json)")
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
    var authentication = GlobalVars.authentication
    var event: CalendarEventSM
    
    init(_ event: CalendarEventSM) {
        self.event = event
    }
}
struct UpdateEventReqBody : Codable {
    var authentication = GlobalVars.authentication
    var updated_event: CalendarEventSM
    
    init(_ event: CalendarEventSM) {
        self.updated_event = event
    }
}
