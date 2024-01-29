//
//  CreateGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 10/25/23.
//

import Foundation
import SwiftUI

struct EditGoalView: View {
    @State var goalName: String = ""
    @State var priorityLevel: Int = 2
    @State var startDate: Date = Date.now
    @State var hasDeadline: YesNoPickerOption = .no
    @State var deadlineDate: Date = Date.now
    @State var howMuchPlannedText: String = ""
    @State var howMuchPlanned: Double = 1
    @State var measuringStyle: MeasuringStylePickerOption = .simple
    @State var measuringUnits: String?
    @State var displayWarning: Bool = false
    
    let desireId: Int
    
    init(desireId: Int, goal: GoalLM? = nil) {
        self.desireId = desireId
        if let goal = goal {
            self._goalName = State(initialValue: goal.name.capitalized)
            self._priorityLevel = State(initialValue: goal.priorityLevel)
            self._startDate = State(initialValue: Date.now)
            self._deadlineDate = State(initialValue: goal.deadlineDate ?? Date.now)
            self._howMuchPlanned = State(initialValue: goal.howMuch)
            self._measuringUnits = State(initialValue: measuringUnits)
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            TextField("Goal Name", text: $goalName)
                .font(.title3)
            HStack {
                Text("Deadline?")
                    .font(.body)
                Picker("", selection: $hasDeadline, content: {
                    ForEach(YesNoPickerOption.allCases) { option in
                        Text(option.rawValue.capitalized)
                    }
                })
                .pickerStyle(.segmented)
                DatePicker("", selection: $deadlineDate, displayedComponents: .date)
                    .opacity(hasDeadline == YesNoPickerOption.yes ? 1 : 0)
                Spacer()
            }
            /*HStack {
             Text("Progress Measuring:")
             Picker("?", selection: $measuringStyle, content: {
             ForEach(MeasuringStylePickerOption.allCases){ option in
             Text(option.rawValue.capitalized)
             }
             })
             Spacer()
             }*/
            VStack (spacing: 0) {
                HStack {
                    Text("Goal Amount: ")
                    TextField("", text: $howMuchPlannedText)
                        .lineLimit(1)
                        .onChange(of: howMuchPlannedText) { text in
                            // check length
                            if text.count > 7 {
                                howMuchPlannedText.removeLast()
                            }
                            // check if valid number
                            howMuchPlanned = Double(howMuchPlannedText) ?? -1
                            if howMuchPlanned < 0 {
                                displayWarning = true
                            } else {
                                displayWarning = false
                            }
                        }
                        .multilineTextAlignment(.center)
                        .background{
                            RoundedRectangle(cornerRadius: 15).fill(Colors.backgroundWhite)
                        }
                        .frame(maxWidth: 60)
                    Spacer()
                }
                HStack {
                    if !displayWarning {
                        Text("Eg: If your goal to read 5 books,\nthe goal amount is 5")
                            .font(.body)
                            .foregroundStyle(Colors.backgroundGray)
                    } else {
                        Text("Goal Amount must be a number greater than 0")
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                }
            }
            HStack(spacing: 0){
                Text("Priority Level:")
                    .font(.body)
                Picker("What priority level is this?", selection: $priorityLevel, content: {
                    ForEach(GlobalVars.userPreferences.priorityLevels, id: \.self){ priorityLevel in
                        Text(GlobalVars.userPreferences.getDescriptionOfPriority(priorityLevel))
                    }
                })
                .pickerStyle(.segmented)
                Spacer()
            }
        }
    }
    enum YesNoPickerOption: String, CaseIterable, Identifiable {
        var id: Self {self}
        case no
        case yes
    }
    enum MeasuringStylePickerOption: String, CaseIterable, Identifiable {
        var id: Self {self}
        case simple
        case detailed
    }
}

struct CreateGoalViewPreview: PreviewProvider {
    static var previews: some View {
        @State var navigationPath = NavigationPath()
        EditGoalView(desireId: 1)
    }
}
