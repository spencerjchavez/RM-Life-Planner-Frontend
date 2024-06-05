//
//  GoalSMServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/31/23.
//

import Foundation

struct GoalServices {
    static let url = GlobalVars.GOALS_URL
    static let timeout = GlobalVars.TIMEOUT_INTERVAL

    static func create(_ goal: GoalSM, authentication: Authentication) async throws -> Int {
        let data = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateGoalReqBody(goal, authentication: authentication))
        if let json = try? JSONDecoder().decode([String: Int].self, from: data) {
            if let goalId = json["goal_id"] {
                return goalId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse goalId from dict: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse goalId from json: \(data)")
        }
    }
    static func delete(_ goalId: Int, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(goalId)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    static func update(_ goalId: Int, _ goal: GoalSM, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(goalId)"), httpMethod: "PUT", httpBodyToEncode: UpdateGoalReqBody(goal, authentication: authentication))
    }
    static func getById(_ goalId: Int, authentication: Authentication) async throws -> GoalSM {
        let data = try await JSONRetriever.getJson(
            url: GlobalVars.GET_TODO_BY_ID_URL.appending(path: "/\(goalId)"),
            httpMethod: "GET",
            queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: GoalSM].self, from: data) {
            if let goal = json["goal"] {
                return goal
            } else {
                throw RMLifePlannerError.serverError("couldn't parse goal from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse goal from json: \(data)")
        }
    }
    
    static func getByDates(_ dates: [String], authentication: Authentication) async throws -> [String: [GoalSM]] {
        if dates.isEmpty {
            return [:]
        }
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_GOALS_IN_DATE_LIST_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: dates,
                                                   queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [String: [GoalSM]]].self, from: data) {
            if let goalsByGoal = json["goals"] {
                return goalsByGoal
            } else {
                throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse goals from json: \(data)")
        }
    }
    
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil, authentication: Authentication) async throws -> [GoalSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate)]
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "end_date", value: endDate))
        }
        queryItems.append(contentsOf: authentication.authQueryItems())
                                                            
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_GOALS_IN_DATE_RANGE_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let json = try? JSONDecoder().decode([String: [GoalSM]].self, from: data) {
            if let goals = json["goals"] {
                return goals
            } else {
                throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse goals from json: \(data)")
        }
    }
}

struct CreateGoalReqBody : Codable {
    let goal: GoalSM
    let authentication: Authentication
    
    init(_ goal: GoalSM, authentication: Authentication) {
        self.goal = goal
        self.authentication = authentication
    }
}
struct UpdateGoalReqBody: Codable {
    let updated_goal: GoalSM
    let authentication: Authentication
    
    init(_ goal: GoalSM, authentication: Authentication) {
        self.updated_goal = goal
        self.authentication = authentication
    }
}
