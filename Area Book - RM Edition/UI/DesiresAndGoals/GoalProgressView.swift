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
    var events: [CalendarEventLM]
    
    init(_ goal: GoalLM) {
        self.goal = goal
        self.events = []
    }
    
    var body: some View {
            VStack {
                Text(goal.name)
                    .font(.body)
                ProgressView(value: 0.8)
                    .background(Colors.lightGray)
                    .tint(.white)
            }
    }
}
