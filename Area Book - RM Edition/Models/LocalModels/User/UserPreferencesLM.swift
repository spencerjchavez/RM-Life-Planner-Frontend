//
//  UserPreferences.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/9/23.
//

import Foundation
import SwiftUI

struct UserPreferencesLM {
    
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
    
    init(from sm: UserPreferencesSM) {
        self.init(
            veryHighPriorityColor: Color(fromHex: sm.veryHighPriorityColor),
            highPriorityColor: Color.init(fromHex: sm.highPriorityColor),
            mediumPriorityColor: Color.init(fromHex: sm.mediumPriorityColor),
            lowPriorityColor: Color.init(fromHex: sm.lowPriorityColor))
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
