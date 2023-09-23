//
//  GoalProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct GoalProgressView: View {
    
    var goal: GoalLM
    
    init(_ goal: GoalLM) {
        self.goal = goal
    }
    
    var body: some View {
        VStack {
            Text(goal.name)
            Capsule()
                .overlay(alignment: .leading) {
                    Rectangle().fill(Colors.lightBlue)
                }
        }
    }
}
