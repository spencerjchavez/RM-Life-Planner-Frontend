//
//  Constants.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/31/23.
//

import Foundation

struct GlobalVars {


    
    static let BASE_URL = URL(string: "http://localhost:8000/api")! //URL(string: "http://191.101.1.153/api")!
    static let USERS_URL = BASE_URL.appending(path: "/users")
    
    static let CALENDAR_EVENTS_URL = BASE_URL.appending(path: "/calendar/events")
    static let GET_CALENDAR_EVENT_BY_ID_URL = CALENDAR_EVENTS_URL.appending(path: "/by-event-id")
    static let GET_CALENDAR_EVENTS_IN_DATE_RANGE_URL = CALENDAR_EVENTS_URL.appending(path: "/in-date-range")
    static let GET_CALENDAR_EVENTS_IN_DATE_LIST_URL = CALENDAR_EVENTS_URL.appending(path: "/in-date-list")
    static let GET_CALENDAR_EVENTS_BY_GOAL_ID_URL = CALENDAR_EVENTS_URL.appending(path: "/by-goal-id")

    static let CALENDAR_ALERTS_URL = BASE_URL.appending(path: "/calendar/alerts")
    
    static let CALENDAR_TODOS_URL = BASE_URL.appending(path: "/calendar/todos")
    static let GET_TODO_BY_ID_URL = CALENDAR_TODOS_URL.appending(path: "/by-todo-id")
    static let GET_TODOS_IN_DATE_RANGE_URL = CALENDAR_TODOS_URL.appending(path: "/in-date-range")
    static let GET_TODOS_IN_DATE_LIST_URL = CALENDAR_TODOS_URL.appending(path: "/in-date-list")
    static let GET_TODOS_BY_GOAL_ID_URL = CALENDAR_TODOS_URL.appending(path: "/by-goal-id")
    
    static let CALENDAR_RECURRENCES_URL = BASE_URL.appending(path: "/calendar/recurrences")
    
    static let DESIRES_URL = BASE_URL.appending(path: "/desires")
    static let GOALS_URL = BASE_URL.appending(path: "/goals")
    static let GET_GOAL_BY_ID_URL = GOALS_URL.appending(path: "/by-event-id")
    static let GET_GOALS_IN_DATE_RANGE_URL = GOALS_URL.appending(path: "/in-date-range")
    static let GET_GOALS_IN_DATE_LIST_URL = GOALS_URL.appending(path: "/in-date-list")
        
    static let TIMEOUT_INTERVAL = 2.0
    
    static let SUBSYSTEM_STR = "RM LIFE PLANNER"
}
