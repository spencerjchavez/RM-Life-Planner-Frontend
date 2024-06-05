//
//  UserSMServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct UserServices {
        
    static func login(_ login: LoginRequest) async throws -> (authentication: Authentication, userPreferences: UserPreferencesSM) {
        let data = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/login"), httpMethod: "POST", httpBodyToEncode: login)
        if let obj = try? JSONDecoder().decode(LoginResult.self, from: data) {
            return (authentication: obj.authentication, userPreferences: obj.user_preferences)
        } else {
            throw RMLifePlannerError.serverError("Could not parse data: \(String(data: data, encoding: .utf8) ?? "non paseable")")
        }
    }
    
    static func logout(authentication: Authentication) async throws {
        _ = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/logout/\(authentication.user_id)"), httpMethod: "POST", httpBodyToEncode: authentication)
    }
    static func create(_ registerRequest: RegisterRequest) async throws -> (authentication: Authentication, userPreferences: UserPreferencesSM) {
        let data = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/register"), httpMethod: "POST", httpBodyToEncode: registerRequest)
        if let obj = try? JSONDecoder().decode(LoginResult.self, from: data) {
            return (authentication: obj.authentication, userPreferences: obj.user_preferences)
        } else {
            throw RMLifePlannerError.serverError("Could not parse data: \(String(data: data, encoding: .utf8) ?? "non paseable")")
        }
        
    }
    static func get(authentication: Authentication) async throws -> UserSM {
        let data = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(authentication.user_id)"), httpMethod: "GET", queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: UserSM].self, from: data) {
            if let user = json["user"] {
                return user
            } else {
                throw RMLifePlannerError.serverError("Could not parse user from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("Could not parse user from data: \(data)")
        }
    }
    
    static func update(_ user: UserSM, authentication: Authentication) async throws {
        let data = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(user.userId)"), httpMethod: "PUT", httpBodyToEncode: UpdateUserReqBody(user, authentication))
    }
    
    static func delete(authentication: Authentication) async throws {
        let json = try await JSONRetriever.getJson(url: GlobalVars.USERS_URL.appending(path: "/\(authentication.user_id)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    
    struct UpdateUserReqBody : Codable {
        let updated_user: UserSM
        let authentication: Authentication
        
        init(_ user: UserSM, _ authentication: Authentication) {
            self.updated_user = user
            self.authentication = authentication
        }
    }
    struct LoginResult : Codable {
        var authentication: Authentication
        var user_preferences: UserPreferencesSM
        
        init(authentication: Authentication, user_preferences: UserPreferencesSM) {
            self.authentication = authentication
            self.user_preferences = user_preferences
        }
    }
}
