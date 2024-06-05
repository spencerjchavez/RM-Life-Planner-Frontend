//
//  DesireWithGoals.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 2/11/24.
//

import Foundation

class DesiresWithGoals: ObservableObject {
    
    @Published var desiresWithGoals: [DesireWithGoals]
    
    init(desires: [DesireLM], goalsByDesireId: [Int:[GoalLM]]) {
        desiresWithGoals = []
        for desire in desires {
            let goals = goalsByDesireId[desire.desireId] ?? []
            desiresWithGoals.append(DesireWithGoals(desire: desire, goals: goals))
        }
    }
}
class DesireWithGoals: ObservableObject, Hashable {
    static func == (lhs: DesireWithGoals, rhs: DesireWithGoals) -> Bool {
        if lhs.desire == rhs.desire {
            if lhs.goals.count == rhs.goals.count {
                for i in lhs.goals.indices {
                    if lhs.goals[i] != rhs.goals[i] {
                        return false
                    }
                }
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.desire)
        for goal in self.goals {
            hasher.combine(goal)
        }
    }
    
    @Published var desire: DesireLM
    @Published var goals: [GoalLM]
    
    init(desire: DesireLM, goals: [GoalLM]) {
        self.desire = desire
        self.goals = goals
    }
}
