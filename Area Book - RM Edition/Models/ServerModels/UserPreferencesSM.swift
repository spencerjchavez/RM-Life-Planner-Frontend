//
//  UserPreferencesSM.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/9/23.
//

import Foundation
import SwiftUI

struct UserPreferencesSM : Codable {
    // expects "#ffffff" hex format
    var veryHighPriorityColor: String
    var highPriorityColor: String
    var mediumPriorityColor: String
    var lowPriorityColor: String
            
    init(veryHighPriorityColor: String, highPriorityColor: String, mediumPriorityColor: String, lowPriorityColor: String) {
        self.veryHighPriorityColor = veryHighPriorityColor
        self.highPriorityColor = highPriorityColor
        self.mediumPriorityColor = mediumPriorityColor
        self.lowPriorityColor = lowPriorityColor
    }
    
    init(from lm: UserPreferencesLM) {
        self.init(
            veryHighPriorityColor: lm.veryHighPriorityColor.hexString(),
            highPriorityColor: lm.highPriorityColor.hexString(),
            mediumPriorityColor: lm.mediumPriorityColor.hexString(),
            lowPriorityColor: lm.lowPriorityColor.hexString())
    }
}
