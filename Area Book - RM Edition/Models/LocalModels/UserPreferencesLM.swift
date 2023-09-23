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
    
    var highestPriorityColor: Color
    var veryHighPriorityColor: Color
    var highPriorityColor: Color
    var mediumPriorityColor: Color
    var lowPriorityColor: Color
        
    init(highestPriorityColor: Color, veryHighPriorityColor: Color, highPriorityColor: Color, mediumPriorityColor: Color, lowPriorityColor: Color) {
        self.highestPriorityColor = highestPriorityColor
        self.veryHighPriorityColor = veryHighPriorityColor
        self.highPriorityColor = highPriorityColor
        self.mediumPriorityColor = mediumPriorityColor
        self.lowPriorityColor = lowPriorityColor
    }
    
    func getColorOfPriority(_ priorityLevel: Int) -> Color{
        if priorityLevel == 1 { return self.highestPriorityColor}
        if priorityLevel == 2 { return self.veryHighPriorityColor}
        if priorityLevel == 3 { return self.highPriorityColor}
        if priorityLevel == 4 { return self.mediumPriorityColor}
        else { return self.lowPriorityColor}
    }
}
