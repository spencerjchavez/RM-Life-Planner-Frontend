//
//  CreateGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 10/25/23.
//

import Foundation
import SwiftUI

    struct EditGoalView : View {
        let desire: DesireLM
        let isNewGoal: Bool
        var todos: [TodoLM]
        @EnvironmentObject var appManager: RMLifePlannerManager
        @Binding var navigationPath: [GoalAchievingNavigationItem]
        @State var goal: GoalLM
        @State var hasDeadline: YesNoPickerOption
        @State var deadlineDate: Date
        @State var howMuchPlannedText: String = ""
        @State var displayWarning: Bool = false // displays warning if howMuchPlanned is not a valid integer
        // TODO: figure out what to do with measuring unit stuff
        @State var measuringStyle: MeasuringStylePickerOption = .simple
        
        // editing existing goal
        init(desire: DesireLM, goal: GoalLM, todos: [TodoLM], navigationPath: Binding<[GoalAchievingNavigationItem]>) {
            self.desire = desire
            self.isNewGoal = false
            if let deadlineDate = goal.deadlineDate {
                self._hasDeadline = State(initialValue: .yes)
                self._deadlineDate = State(initialValue: deadlineDate)
            } else {
                self._hasDeadline = State(initialValue: .no)
                self._deadlineDate = State(initialValue: Date.now)
            }
            self._howMuchPlannedText = State(initialValue: "1")
            self._goal = State(initialValue: goal)
            self.todos = todos
            self._navigationPath = navigationPath
        }
        
        // create new goal
        init(desire: DesireLM, navigationPath: Binding<[GoalAchievingNavigationItem]>) {
            self.desire = desire
            self.isNewGoal = true
            self._hasDeadline = State(initialValue: .no)
            self._deadlineDate = State(initialValue: Date.now)
            self._howMuchPlannedText = State(initialValue: "1")
            self._navigationPath = navigationPath
            self._goal = State(initialValue: GoalLM(desireId: desire.desireId, userId: desire.userId, name: "", howMuch: 1, startDate: Date.now, priorityLevel: 1))
            self.todos = []
        }
        
        var body: some View {
            VStack {
                Text(self.desire.name.capitalized)
                    .fontWeight(.medium)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: 3)
                    .foregroundStyle(Colors.backgroundOffWhite)
                    .padding(.bottom)
                VStack(spacing: 4) {
                    TextField("Short-Term Goal", text: self.$goal.name)
                        .font(.title3)
                    HStack {
                        Text("Set Deadline?")
                            .font(.body)
                        Picker("", selection: $hasDeadline, content: {
                            ForEach(YesNoPickerOption.allCases) { option in
                                Text(option.rawValue.capitalized)
                            }
                        })
                        .pickerStyle(.segmented)
                        .onChange(of: hasDeadline) { hasDeadline in
                            if hasDeadline == .yes {
                                self.goal.deadlineDate = deadlineDate
                            } else {
                                self.goal.deadlineDate = nil
                            }
                        }
                        DatePicker("", selection: $deadlineDate, displayedComponents: .date)
                            .opacity(hasDeadline == YesNoPickerOption.yes ? 1 : 0)
                            .onChange(of: deadlineDate) { deadlineDate in
                                if self.hasDeadline == .yes {
                                    self.goal.deadlineDate = deadlineDate
                                }
                            }
                        Spacer()
                    }
                    
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
                                    let howMuchPlanned = Double(howMuchPlannedText) ?? -1
                                    if howMuchPlanned < 0 {
                                        displayWarning = true
                                    } else {
                                        displayWarning = false
                                        self.goal.howMuch = howMuchPlanned
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
                        Picker("What priority level is this?", selection: self.$goal.priorityLevel, content: {
                            ForEach(appManager.userPreferences?.priorityLevels ?? [], id: \.self){ priorityLevel in
                                Text(appManager.userPreferences?.getDescriptionOfPriority(priorityLevel) ?? "Error")
                            }
                        })
                        .pickerStyle(.segmented)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(appManager.userPreferences?.getColorOfPriority(self.goal.priorityLevel).opacity(0.5) ?? Colors.accentColorLight))
                
                // buttons :D
                HStack {
                    // delete button
                    Button {
                        guard let authentication = appManager.authentication else {
                            return
                        }
                        self.appManager.goalsManager.deleteGoal(goalId: goal.goalId)
                        navigationPath.removeLast()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.7)))
                    }
                    // cancel button
                    Button {
                        // revert changes
                        navigationPath.removeLast()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Colors.backgroundOffWhite))
                    }.padding()
                    
                    // save changes button
                    Button {
                        if self.isNewGoal {
                            // create new goal
                            _ = appManager.goalsManager.createGoal(goal: goal)
                            let todo = TodoLM(userId: goal.userId, name: goal.name, startDate: goal.startDate, howMuchPlanned: goal.howMuch, linkedGoalId: goal.goalId)
                            _ = appManager.todosManager.createTodo(todo: todo)
                        } else {
                            // editing existing goal
                            appManager.goalsManager.updateGoal(goalId: goal.goalId, updatedGoal: goal)
                            for var todo in todos {
                                todo.name = goal.name
                                todo.deadlineDate = goal.deadlineDate
                                todo.howMuchPlanned = goal.howMuch
                                todo.startDate = goal.startDate
                                appManager.todosManager.updateTodo(todoId: todo.todoId, updatedTodo: todo)
                            }
                        }
                        navigationPath.removeLast()
                    } label: {
                        Text("Save Short-Term Goal")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Colors.accentColorLight))
                    }
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
    //}
}

struct CreateGoalViewPreview: PreviewProvider {
    static var previews: some View {
        @State var navPath: [GoalAchievingNavigationItem] = []
        @State var goal: GoalLM = GoalLM(desireId: 1, userId: 1, name: "", howMuch: 0, startDate: Date.now, priorityLevel: 1)
        @State var todo: TodoLM = TodoLM(userId: 1, name: "", startDate: Date.now, howMuchPlanned: 0, linkedGoalId: goal.goalId)
        EditGoalView(desire: DesireLM(name: "desire1", userId: 1), goal: goal, todos: [todo], navigationPath: $navPath)
    }
}
