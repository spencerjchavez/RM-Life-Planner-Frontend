//
//  UserSMServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct UserSMServices {
        
    static func login(username: String, password: String) async throws {
        let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/login"), httpMethod: "POST", queryItems: [URLQueryItem(name: "username", value: username), URLQueryItem(name: "password", value: password)])
        if let auth = json["authentication"] as? Authentication {
            GlobalVars.authentication = auth
        } else {
            throw RMLifePlannerError.serverError("couldn't parse authentication from json: \(json)")
        }
    }
    
    static func logout() async throws {
        if let authentication = GlobalVars.authentication {
            let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/logout/\(authentication.user_id)"), httpMethod: "POST", httpBodyToEncode: authentication)
        } else {
            throw RMLifePlannerError.clientError
        }
    }
    static func create(_ user: UserSM) async throws -> Int {
        if let authentication = GlobalVars.authentication {
            let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/register"), httpMethod: "POST", httpBodyToEncode: user)
            if let userId = json["user_id"] as? Int {
                return userId
            } else {
                throw RMLifePlannerError.serverError("Could not parse user_id from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.clientError
        }
    }
    static func get() async throws -> UserSM {
        if let authentication = GlobalVars.authentication {
            let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(authentication.user_id)"), httpMethod: "GET", queryItems: GlobalVars.authQueryItems)
            if let user = json["user"] as? UserSM {
                return user
            } else {
                throw RMLifePlannerError.serverError("Could not parse user from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.clientError
        }
    }
    
    static func update(_ user: UserSM) async throws {
        if let authentication = GlobalVars.authentication {
            let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(user.userId)"), httpMethod: "PUT", httpBodyToEncode: UpdateUserReqBody(user))
        } else {
            throw RMLifePlannerError.clientError
        }
    }
    
    static func delete() async throws {
        if let authentication = GlobalVars.authentication {
            let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(authentication.user_id)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
        } else {
            throw RMLifePlannerError.clientError
        }
    }
    
    struct UpdateUserReqBody : Codable {
        let updated_user: UserSM
        let authentication: Authentication
        
        init(_ user: UserSM) {
            self.updated_user = user
            self.authentication = GlobalVars.authentication!
        }
    }
}
