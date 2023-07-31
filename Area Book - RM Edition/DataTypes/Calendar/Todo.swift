//
//  Todo.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct Todo {
    enum Timeframe {
        case INDEFINITE
        case DAY
        case WEEK
        case MONTH
        case YEAR
    }
    var todoId: Int
    var userId: Int
    
    var name: String
    var startInstant: Double
    var deadline: Double
    
    var recurrenceId: Int
    var timeframe: Timeframe
    var linkedGoalId: Int
}
