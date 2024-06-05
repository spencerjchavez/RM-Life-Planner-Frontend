//
//  GoalAchievingNavigationItem.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 2/12/24.
//

import Foundation

struct GoalAchievingNavigationItem : Hashable {
    let viewType: ViewType
    let desire: DesireLM?
    let goal: GoalLM?
    
    init(viewType: ViewType, desire: DesireLM? = nil, goal: GoalLM? = nil) {
        self.viewType = viewType
        self.desire = desire
        self.goal = goal
    }
    
    enum ViewType : String, Hashable {
        case editDesire
        case editGoal
        case createDesire
        case createGoal
    }
}
