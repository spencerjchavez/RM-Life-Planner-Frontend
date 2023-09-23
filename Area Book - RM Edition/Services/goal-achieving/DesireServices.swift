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

    static func create(_ desire: DesireSM) async throws -> Int {
        let json = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateDesireReqBody(desire))
        if let desireId = json["desire_id"] as? Int {
            return desireId
        } else {
            throw RMLifePlannerError.serverError("couldn't parse desireId from json: \(json)")
        }
    }
    static func delete(_ desireId: Int) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(desireId)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
    }
    static func update(_ desireId: Int, _ desire: DesireSM) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(desireId)"), httpMethod: "PUT", httpBodyToEncode: UpdateDesireReqBody(desire))
    }
    static func get(_ desireId: Int) async throws -> DesireSM {
        let json = try await JSONRetriever.getJson(
            url: url.appending(path: "/\(desireId)"),
            httpMethod: "GET",
            queryItems: GlobalVars.authQueryItems)
        if let data = json["desire"] as? Data {
            do {
                return try JSONDecoder().decode(DesireSM.self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse desire from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse desire from json: \(json)")
        }
    }
    static func getAll() async throws -> [DesireSM] {
        let json = try await JSONRetriever.getJson(url: url.appending(path: "/by-user-id/\(GlobalVars.authentication!.user_id)"),
                                         httpMethod: "GET",
                                         queryItems: GlobalVars.authQueryItems)
        if let desires = json["desires"] as? [DesireSM] {
            return desires
        } else {
            throw RMLifePlannerError.serverError("could not parse desires from json: \(json)")
        }
    }
}
struct CreateDesireReqBody : Codable {
    var authentication = GlobalVars.authentication
    var desire: DesireSM
    
    init(_ desire: DesireSM) {
        self.desire = desire
    }
}
struct UpdateDesireReqBody : Codable {
    var authentication = GlobalVars.authentication
    var updated_desire: DesireSM
    
    init(_ desire: DesireSM) {
        self.updated_desire = desire
    }
}
