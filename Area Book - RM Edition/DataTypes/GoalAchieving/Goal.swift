//
//  Goal.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct Goal {
    enum Timeframe {
        case INDEFINITE
        case DAY
        case WEEK
        case MONTH
        case YEAR
    }
    
    var goalId: Int?
    var desireId: Int
    var userId: Int
    var name: String
    var howMuch: Int
    var measuringUnits: String?
    var startInstant: Double
    var deadline: Double?
    var recurrenceId: Int?
    var timeframe: Timeframe?
    
    init(goalId: Int? = nil, desireId: Int, userId: Int, name: String, howMuch: Int, measuringUnits: String? = nil, startInstant: Double, deadline: Double? = nil) {
        self.goalId = goalId
        self.desireId = desireId
        self.userId = userId
        self.name = name
        self.howMuch = howMuch
        self.measuringUnits = measuringUnits
        self.startInstant = startInstant
        self.deadline = deadline
    }
    
    init(goalId: Int? = nil, desireId: Int, userId: Int, name: String, howMuch: Int, measuringUnits: String? = nil, startInstant: Double, deadline: Double? = nil, recurrenceId: Int, timeframe: Timeframe) {
        self.goalId = goalId
        self.desireId = desireId
        self.userId = userId
        self.name = name
        self.howMuch = howMuch
        self.measuringUnits = measuringUnits
        self.startInstant = startInstant
        self.deadline = deadline
        self.recurrenceId = recurrenceId
        self.timeframe = timeframe
    }
}
