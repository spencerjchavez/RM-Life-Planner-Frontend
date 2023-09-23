//
//  CreateGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 10/25/23.
//

import Foundation
import SwiftUI

struct CreateGoalView: View {
    
    @Binding var navigationPath: NavigationPath
    @State var goalName: String = ""
    @State var desireId: Int?
    @State var priorityLevel: Int = 0
    
    
    init(desireId: Int? = nil, navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
        self.desireId = desireId
    }
    
    var body: some View {
        VStack {
            Picker("What priority level is this?", selection: $priorityLevel, content: {
                Text("Select a priority level:")
                ForEach(GlobalVars.userPreferences.priorityLevels, id: \.self){ priorityLevel in
                    Text(GlobalVars.userPreferences.getDescriptionOfPriority(priorityLevel))
                }
            })
        }
        
    }
    func submit() {
        
    }
    func back() {
        navigationPath.removeLast()
    }
}

struct CreateGoalViewPreview: PreviewProvider {
    static var previews: some View {
        @State var navigationPath = NavigationPath()
        CreateGoalView(navigationPath: $navigationPath)
    }
}
