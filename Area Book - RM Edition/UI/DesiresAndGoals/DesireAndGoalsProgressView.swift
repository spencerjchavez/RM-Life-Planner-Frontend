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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.coolMint)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3.0)
            VStack {
                Text("Get a job after graduation")
                    .font(.title2)
                Rectangle()
                    .fill(Colors.lightGray)
                    .frame(height: 3)
                GoalProgressView(goal1)
                GoalProgressView(goal2)
            }
        }
    }
}
