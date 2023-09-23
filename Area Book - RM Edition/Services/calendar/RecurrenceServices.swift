//
//  RecurrenceServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct RecurrenceServices {
    static let url = GlobalVars.CALENDAR_RECURRENCES_URL
    static let timeout = GlobalVars.TIMEOUT_INTERVAL

    static func create(_ recurrence: RecurrenceSM) async throws -> Int {
        let json = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateRecurrenceReqBody(recurrence))
        if let recurrenceId = json["recurrence_id"] as? Int {
            return recurrenceId
        } else {
            throw RMLifePlannerError.serverError("couldn't parse recurrenceId from json: \(json)")
        }
    }
    static func delete(_ recurrenceId: Int) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(recurrenceId)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
    }
    static func update(_ recurrenceId: Int, _ recurrence: RecurrenceSM, after: String? = nil) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(recurrenceId)"), httpMethod: "PUT", httpBodyToEncode: UpdateRecurrenceReqBody(recurrence), queryItems: [URLQueryItem(name: "after", value: after ?? nil)])
    }
    static func setRecurrenceEnd(_ recurrenceId: Int, date: String) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/put-dtend/\(recurrenceId)"), httpMethod: "PUT", httpBodyToEncode: GlobalVars.authentication!, queryItems: [URLQueryItem(name: "end", value: date)])
    }
    static func get(_ recurrenceId: Int) async throws -> RecurrenceSM {
        let json = try await JSONRetriever.getJson(
            url: url.appending(path: "/\(recurrenceId)"),
            httpMethod: "GET",
            queryItems: GlobalVars.authQueryItems)
        if let data = json["recurrence"] as? Data {
            do {
                return try JSONDecoder().decode(RecurrenceSM.self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse recurrence from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse recurrence from json: \(json)")
        }
    }
}
struct CreateRecurrenceReqBody : Codable {
    var authentication = GlobalVars.authentication
    var recurrence: RecurrenceSM
    
    init(_ recurrence: RecurrenceSM) {
        self.recurrence = recurrence
    }
}
struct UpdateRecurrenceReqBody : Codable {
    var authentication = GlobalVars.authentication
    var updated_recurrence: RecurrenceSM
    
    init(_ recurrence: RecurrenceSM) {
        self.updated_recurrence = recurrence
    }
}
