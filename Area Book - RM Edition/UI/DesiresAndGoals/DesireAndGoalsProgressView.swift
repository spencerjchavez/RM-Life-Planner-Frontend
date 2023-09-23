//
//  DesiresAndGoalsProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct DesireAndGoalsProgressView : View {
    
    var goal1 = GoalLM(desireId: 1, userId: 1, name: "Go to the STEM fair", howMuch: 1, startDate: Date.now)
    var goal2 =  GoalLM(desireId: 1, userId: 1, name: "Complete 5 leet code problems a week", howMuch: 5, startDate: Date.now)
    var desire: DesireLM
    var goals: [GoalLM]
    
    init() {
        self.desire = DesireLM(name: "", userId: 1, dateCreated: Date.now, priorityLevel: 1)
        self.goals = []
    }
    
    init(desire: DesireLM, goals: [GoalLM]) {
        self.desire = desire
        self.goals = goals
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.coolMint)
            VStack {
                Text("Get a job after graduation")
                    .font(.title2)
                    .padding(10)
                GoalProgressView(goal1)
                GoalProgressView(goal2)
            }
                .padding(10)
        }
    }
}
