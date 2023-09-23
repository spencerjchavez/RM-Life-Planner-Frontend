//
//  TodoServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/3/23.
//

import Foundation

struct TodoServices {
    static let url = GlobalVars.CALENDAR_TODOS_URL
    static let timeout = GlobalVars.TIMEOUT_INTERVAL

    static func create(_ todo: TodoSM) async throws -> Int {
        let json = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateTodoReqBody(todo))
        if let todoId = json["todo_id"] as? Int {
            return todoId
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todoId from json: \(json)")
        }
    }
    static func delete(_ todoId: Int) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(todoId)"), httpMethod: "DELETE", queryItems: GlobalVars.authQueryItems)
    }
    static func update(_ todoId: Int, _ todo: TodoSM) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(todoId)"), httpMethod: "PUT", httpBodyToEncode: UpdateTodoReqBody(todo))
    }
    static func getById(_ todoId: Int) async throws -> TodoSM {
        let json = try await JSONRetriever.getJson(
            url: GlobalVars.GET_TODO_BY_ID_URL.appending(path: "/\(todoId)"),
            httpMethod: "GET",
            queryItems: GlobalVars.authQueryItems)
        if let data = json["todo"] as? Data {
            do {
                return try JSONDecoder().decode(TodoSM.self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse todo from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse todo from json: \(json)")
        }
    }
    static func getByDates(_ dates: [String]) async throws -> [String: [TodoSM]] {
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_IN_DATE_LIST_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: dates,
                                                   queryItems: GlobalVars.authQueryItems)
        if let data = json["todos"] as? Data {
            do {
                return try JSONDecoder().decode([String: [TodoSM]].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
        }
    }
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil) async throws -> [TodoSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate),
         URLQueryItem(name: "end_date", value: endDate ?? startDate)]
        queryItems.append(contentsOf: GlobalVars.authQueryItems)
                                                            
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_IN_DATE_RANGE_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let data = json["todos"] as? Data {
            do {
                return try JSONDecoder().decode([TodoSM].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
        }
    }
    static func getByGoalId(_ goalId: Int) async throws -> [TodoSM] {
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_BY_GOAL_ID_URL.appending(path: "/\(goalId)"), httpMethod: "GET", queryItems: GlobalVars.authQueryItems)
        if let data = json["todos"] as? Data {
            do {
                return try JSONDecoder().decode([TodoSM].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
        }
    }
    static func getByGoalIds(_ goalIds: [Int]) async throws -> [Int: [TodoSM]] {
        let json = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_BY_GOAL_ID_URL, httpMethod: "POST", httpBodyToEncode: goalIds, queryItems: GlobalVars.authQueryItems)
        if let data = json["todos"] as? Data {
            do {
                return try JSONDecoder().decode([Int: [TodoSM]].self, from: data)
            } catch {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            // TODO: see if we can parse the server's detail attribute from here
            throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
        }
    }
}

struct CreateTodoReqBody : Codable {
    let todo: TodoSM
    let user_id: Int
    let api_key: String
    
    init(_ todo: TodoSM) {
        self.todo = todo
        self.user_id = GlobalVars.authentication!.user_id
        self.api_key = GlobalVars.authentication!.api_key
    }
}
struct UpdateTodoReqBody : Codable {
    let updated_todo: TodoSM
    let authorization: Authentication
    
    init(_ todo: TodoSM) {
        self.updated_todo = todo
        self.authorization = GlobalVars.authentication!
    }
}
