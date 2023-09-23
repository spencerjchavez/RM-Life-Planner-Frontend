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

    static func create(_ goal: GoalSM) async throws -> Int {
        let json = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateGoalReqBody(goal))
        if let goalId = json["goal_id"] as? Int {
            return goalId
        } else {
            throw RMLifePlannerError.serverError("couldn't parse goalId from json: \(json)")
        }
    }
    static func delete(_ goalId: Int) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(goalId)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
    }
    static func update(_ goalId: Int, _ goal: GoalSM) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(goalId)"), httpMethod: "PUT", httpBodyToEncode: UpdateGoalReqBody(goal))
    }
    static func getById(_ goalId: Int) async throws -> GoalSM {
        let json = try await JSONRetriever.getJson(
            url: GlobalVars.GET_TODO_BY_ID_URL.appending(path: "/\(goalId)"),
            httpMethod: "GET",
            queryItems: GlobalVars.authQueryItems)
        if let data = json["goal"] as? Data {
            do {
                return try JSONDecoder().decode(GoalSM.self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse goal from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse goal from json: \(json)")
        }
    }
    static func getByDates(_ dates: [String]) async throws -> [String: [GoalSM]] {
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_GOALS_IN_DATE_LIST_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: dates,
                                                   queryItems: GlobalVars.authQueryItems)
        if let data = json["goals"] as? Data {
            do {
                return try JSONDecoder().decode([String: [GoalSM]].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
        }
    }
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil) async throws -> [GoalSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate),
         URLQueryItem(name: "end_date", value: endDate ?? startDate)]
        queryItems.append(contentsOf: GlobalVars.authQueryItems)
                                                            
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_GOALS_IN_DATE_RANGE_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let data = json["goals"] as? Data {
            do {
                return try JSONDecoder().decode([GoalSM].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse goals from json: \(json)")
        }
    }
}

struct CreateGoalReqBody : Codable {
    let goal: GoalSM
    let user_id: Int
    let api_key: String
    
    init(_ goal: GoalSM) {
        self.goal = goal
        self.user_id = GlobalVars.authentication!.user_id
        self.api_key = GlobalVars.authentication!.api_key
    }
}
struct UpdateGoalReqBody: Codable {
    let updated_goal: GoalSM
    let authentication: Authentication
    
    init(_ goal: GoalSM) {
        self.updated_goal = goal
        self.authentication = GlobalVars.authentication!
    }
}
