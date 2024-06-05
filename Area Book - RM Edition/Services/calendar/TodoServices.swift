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

    static func create(_ todo: TodoSM, authentication: Authentication) async throws -> Int {
        let data = try await JSONRetriever.getJson(url: url, httpMethod: "POST", httpBodyToEncode: CreateTodoReqBody(todo, authentication: authentication))
        if let json = try? JSONDecoder().decode([String: Int].self, from: data) {
            if let todoId = json["todo_id"] {
                return todoId
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todoId from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todoId from data: \(String(data: data, encoding: .utf8) ?? "non-parseable")")
        }
    }
    static func delete(_ todoId: Int, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(todoId)"), httpMethod: "DELETE", queryItems: authentication.authQueryItems())
    }
    static func update(_ todoId: Int, _ todo: TodoSM, authentication: Authentication) async throws {
        let _ = try await JSONRetriever.getJson(url: url.appending(path: "/\(todoId)"), httpMethod: "PUT", httpBodyToEncode: UpdateTodoReqBody(todo, authentication: authentication))
    }
    static func getById(_ todoId: Int, authentication: Authentication) async throws -> TodoSM {
        let data = try await JSONRetriever.getJson(
            url: GlobalVars.GET_TODO_BY_ID_URL.appending(path: "/\(todoId)"),
            httpMethod: "GET",
            queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: TodoSM].self, from: data) {
            if let todo = json["todo"] {
                return todo
                
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todo from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todo from data: \(data)")
        }
    }
    
    static func getByDates(_ dates: [String], authentication: Authentication) async throws -> [String: [TodoSM]] {
        if dates.isEmpty {
            return [:]
        }
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_IN_DATE_LIST_URL,
                                                   httpMethod: "POST",
                                                   httpBodyToEncode: dates,
                                                   queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [String: [TodoSM]]].self, from: data) {
            if let todosByDate = json["todos"] {
                return todosByDate
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todos from data: \(data)")
        }
    }
    
    static func getByDateRange(_ startDate: String, _ endDate: String? = nil, authentication: Authentication) async throws -> [TodoSM] {
        var queryItems = [URLQueryItem(name: "start_date", value: startDate)]
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "end_date", value: endDate))
        }
        queryItems.append(contentsOf: authentication.authQueryItems())
                                                            
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_IN_DATE_RANGE_URL,
                                                   httpMethod: "GET",
                                                   queryItems: queryItems)
        if let json = try? JSONDecoder().decode([String: [TodoSM]].self, from: data) {
            if let todos = json["todos"] {
                return todos
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todos from data: \(data)")
        }
    }
    static func getByGoalId(_ goalId: Int, authentication: Authentication) async throws -> [TodoSM] {
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_BY_GOAL_ID_URL.appending(path: "/\(goalId)"), httpMethod: "GET", queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [TodoSM]].self, from: data) {
            if let todos = json["todos"] {
                return todos
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todos from data: \(String(data: data, encoding: .utf8) ?? "non-parseable")")
        }
    }
    
    static func getByGoalIds(_ goalIds: [Int], authentication: Authentication) async throws -> [Int: [TodoSM]] {
        if goalIds.isEmpty {
            return [:]
        }
        let data = try await JSONRetriever.getJson(url: GlobalVars.GET_TODOS_BY_GOAL_ID_URL, httpMethod: "POST", httpBodyToEncode: goalIds, queryItems: authentication.authQueryItems())
        if let json = try? JSONDecoder().decode([String: [Int: [TodoSM]]].self, from: data) {
            if let todos = json["todos"] {
                return todos
            } else {
                throw RMLifePlannerError.serverError("couldn't parse todos from json: \(json)")
            }
        } else {
            throw RMLifePlannerError.serverError("couldn't parse todos from data: \(String(data: data, encoding: .utf8) ?? "non-parseable")")
        }
    }
}

struct CreateTodoReqBody : Codable {
    let todo: TodoSM
    let authentication: Authentication

    init(_ todo: TodoSM, authentication: Authentication) {
        self.todo = todo
        self.authentication = authentication
    }
}
struct UpdateTodoReqBody : Codable {
    let updated_todo: TodoSM
    let authentication: Authentication
    
    init(_ todo: TodoSM, authentication: Authentication) {
        self.updated_todo = todo
        self.authentication = authentication
    }
}
