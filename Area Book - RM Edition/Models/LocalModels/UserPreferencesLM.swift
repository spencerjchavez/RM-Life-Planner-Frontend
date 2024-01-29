//
//  UserPreferences.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/9/23.
//

import Foundation
import SwiftUI

struct UserPreferencesLM {
    
    var primaryColor: Color = .white
    var secondaryColor: Color = .red
    var accentColor: Color = .blue
    var accentColor2: Color = .brown
    
    var veryHighPriorityColor: Color
    var highPriorityColor: Color
    var mediumPriorityColor: Color
    var lowPriorityColor: Color
    
    let priorityLevels = [1, 2, 3, 4]
        
    init(veryHighPriorityColor: Color, highPriorityColor: Color, mediumPriorityColor: Color, lowPriorityColor: Color) {
        self.veryHighPriorityColor = veryHighPriorityColor
        self.highPriorityColor = highPriorityColor
        self.mediumPriorityColor = mediumPriorityColor
        self.lowPriorityColor = lowPriorityColor
    }
    
    func getColorOfPriority(_ priorityLevel: Int) -> Color {
        if priorityLevel == 1 { return self.veryHighPriorityColor}
        if priorityLevel == 2 { return self.highPriorityColor}
        if priorityLevel == 3 { return self.mediumPriorityColor}
        else { return self.lowPriorityColor}
    }
    func getDescriptionOfPriority(_ priorityLevel: Int) -> String {
        if priorityLevel == 1 { return "Highest"}
        if priorityLevel == 2 { return "High"}
        if priorityLevel == 3 { return "Med"}
        else { return "Low"}
    }
}
