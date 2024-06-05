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

    static func create(_ recurrence: RecurrenceSM, authentication: Authentication) async throws -> Int {
        let data = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateRecurrenceReqBody(recurrence, authentication: authentication))
        if let json = try? JSONDecoder().decode([String: Int].self, from: data) {
            if let recurrenceId = json["recurrence_id"] {
                return recurrenceId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse recurrence_id from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse recurrence_id from data: \(data)")
        }
    }
    static func delete(_ recurrenceId: Int, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(recurrenceId)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    static func update(_ recurrenceId: Int, _ recurrence: RecurrenceSM, after: String? = nil, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(recurrenceId)"), httpMethod: "PUT", httpBodyToEncode: UpdateRecurrenceReqBody(recurrence, authentication: authentication), queryItems: [URLQueryItem(name: "after", value: after ?? nil)])
    }
    static func setRecurrenceEnd(_ recurrenceId: Int, date: String, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/put-dtend/\(recurrenceId)"), httpMethod: "PUT", httpBodyToEncode: authentication, queryItems: [URLQueryItem(name: "end", value: date)])
    }
    static func get(_ recurrenceId: Int, authentication: Authentication) async throws -> RecurrenceSM {
        let data = try await JSONRetriever.getJson(
            url: url.appending(path: "/\(recurrenceId)"),
            httpMethod: "GET",
            queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: RecurrenceSM].self, from: data) {
            if let recurrence = json["recurrence"] {
                return recurrence
            } else {
                throw RMLifePlannerError.serverError("couldn't parse recurrence from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse recurrence from data: \(data)")
        }
    }
}
struct CreateRecurrenceReqBody : Codable {
    var recurrence: RecurrenceSM
    var authentication: Authentication
    
    init(_ recurrence: RecurrenceSM, authentication: Authentication) {
        self.recurrence = recurrence
        self.authentication = authentication
    }
}
struct UpdateRecurrenceReqBody : Codable {
    var updated_recurrence: RecurrenceSM
    var authentication: Authentication
    
    init(_ updated_recurrence: RecurrenceSM, authentication: Authentication) {
        self.updated_recurrence = updated_recurrence
        self.authentication = authentication
    }
}
