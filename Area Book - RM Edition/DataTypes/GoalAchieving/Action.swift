//
//  Action.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct Action {
    enum Success {
        case SUCCESSFUL
        case UNSUCCESSFUL
        case PARTIAL
    }
    
    var planId: Int
    var eventId: Int
    var goalId: Int
    var userId: Int
    var succssful: Success
    var homMuchAccomplished: Int
    var notes: String?
    
    init(planId: Int, eventId: Int, goalId: Int, userId: Int, succssful: Success, homMuchAccomplished: Int, notes: String? = nil) {
        self.planId = planId
        self.eventId = eventId
        self.goalId = goalId
        self.userId = userId
        self.succssful = succssful
        self.homMuchAccomplished = homMuchAccomplished
        self.notes = notes
    }
}
