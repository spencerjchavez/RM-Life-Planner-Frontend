//
//  DesireServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct DesireServices {
    static let url = GlobalVars.DESIRES_URL
    static let timeout = GlobalVars.TIMEOUT_INTERVAL

    static func create(_ desire: DesireSM, authentication: Authentication) async throws -> Int {
        let data = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateDesireReqBody(desire, authentication: authentication))
        if let json = try? JSONDecoder().decode([String: Int].self, from: data) {
            if let desireId = json["desire_id"] {
                return desireId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse desireId from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse desireId from data: \(data)")
        }
    }
    static func delete(_ desireId: Int, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(desireId)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    static func update(_ desireId: Int, _ desire: DesireSM, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(desireId)"), httpMethod: "PUT", httpBodyToEncode: UpdateDesireReqBody(desire, authentication: authentication))
    }
    static func get(_ desireId: Int, authentication: Authentication) async throws -> DesireSM {
        let data = try await JSONRetriever.getJson(
            url: url.appending(path: "/\(desireId)"),
            httpMethod: "GET",
            queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: DesireSM].self, from: data) {
            if let desire = json["desire"] {
                return desire
            } else {
                throw RMLifePlannerError.serverError("couldn't parse desire from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse desire from json: \(data)")
        }
    }

    static func getAll(authentication: Authentication) async throws -> [DesireSM] {
        let data = try await JSONRetriever.getJson(url: url.appending(path: "/by-user-id/\(authentication.user_id)"),
                                         httpMethod: "GET",
                                         queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [DesireSM]].self, from: data) {
            if let desires = json["desires"] {
                return desires
            } else {
                throw RMLifePlannerError.serverError("could not parse desires from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("could not parse desires from json: \(data)")
        }
    }
}
struct CreateDesireReqBody : Codable {
    var authentication: Authentication
    var desire: DesireSM
    
    init(_ desire: DesireSM, authentication: Authentication) {
        self.desire = desire
        self.authentication = authentication
    }
}
struct UpdateDesireReqBody : Codable {
    var authentication: Authentication
    var updated_desire: DesireSM
    
    init(_ desire: DesireSM, authentication: Authentication) {
        self.updated_desire = desire
        self.authentication = authentication
    }
}
