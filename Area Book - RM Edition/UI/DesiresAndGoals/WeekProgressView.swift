//
//  WeekProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 1/11/24.
//

import SwiftUI

struct WeekProgressView: View {
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    @State var editMode: Bool = false
    
    let reportsManager = ReportsManager()
    var report: GoalAchievingReport
    
    @State var newDesireText: String = ""
    @State var newDesireId: Int?
    @FocusState var editingNewDesireName: Bool
    
    @State var updatedDesires: [Int: DesireLM] = [:]
    @State var updatedGoals: [Int: GoalLM] = [:]
    
    @State var test: Bool = false
    
    init(_ report: GoalAchievingReport) {
        self.report = report
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button{
                    // open up prompt to create new priority or goal
                    self.editMode.toggle()
                } label: {
                    Text(editMode ? "Save Changes" : "Edit Mode")
                        .font(.title3)
                }
                .padding(.trailing)
            }
            ScrollView {
                ScrollViewReader { reader in
                    VStack (spacing: 0) {
                        // display holistic progress
                        Text("This Week - \(Int((report.totalProgress*100).rounded()))% Completed")
                            .font(.title)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .background(Colors.backgroundOffWhite)
                            .foregroundColor(Colors.textBody)
                            .padding(.bottom)
                            .onTapGesture {
                                self.editingNewDesireName = false
                            }
                        
                        VStack{
                            // display individual desires + goals
                            ForEach(report.desires, id: \.self) { desire in
                                @State var desireName: String = desire.name
                                @FocusState var isFocused: Bool
                                if editMode {
                                    TextField("Enter a Long-Term Goal", text: $desireName)
                                        .multilineTextAlignment(.center)
                                        .fontWeight(.semibold)
                                        .font(.title2)
                                        .frame(maxWidth: .infinity)
                                        .focused($isFocused)
                                        .onChange(of: isFocused) { isFocused in
                                            if !isFocused {
                                                print("desire name unfocused")
                                                if desireName.isEmpty {
                                                    // revert to old name
                                                    desireName = desire.name
                                                } else {
                                                    // update new name
                                                    var desire = desire
                                                    desire.name = desireName
                                                    updatedDesires[desire.desireId] = desire
                                                }
                                            }
                                        }
                                } else {
                                    Text(desire.name.capitalized)
                                        .fontWeight(.semibold)
                                        .font(.title2)
                                        .foregroundColor(Colors.textSubtitle)
                                        .frame(maxWidth: .infinity)
                                        .onTapGesture {
                                            self.editingNewDesireName = false
                                        }
                                }
                                VStack (spacing: 0) {
                                    ForEach(report.goalsByDesireId[desire.desireId] ?? [], id: \.self) { goal in
                                        let amountAccomplished = report.goalsHowMuchAccomplished[goal.goalId] ?? 0.0
                                        let amountPlanned = report.goalsHowMuchPlanned[goal.goalId] ?? 0.0
                                        let color = GlobalVars.userPreferences.getColorOfPriority(goal.priorityLevel)
                                        if editMode {
                                            EditGoalView(desireId: desire.desireId, goal: goal)
                                                .padding()
                                                .background {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(color).opacity(0.5)
                                                }
                                                .padding(.bottom)
                                                .onTapGesture {
                                                    editingNewDesireName = false
                                                }
                                        } else {
                                            GoalProgressView(
                                                goalName: goal.name,
                                                amountAccomplished: amountAccomplished,
                                                amountPlanned: amountPlanned,
                                                deadlineDate: goal.deadlineDate,
                                                accentColor: color,
                                                backgroundColor: Colors.backgroundWhite)
                                            .background(Capsule().fill(color.opacity(0.5)))
                                            .padding(.bottom)
                                        }
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            self.editingNewDesireName = false
                        }
                        // add prompt to create a new desire here
                        if editMode {
                            VStack {
                                TextField("Enter A New Long-Term Goal", text: $newDesireText)
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                    .foregroundColor(Colors.textSubtitle)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .focused($editingNewDesireName)
                                    .onChange(of: editingNewDesireName) { name in
                                        if !editingNewDesireName && !newDesireText.isEmpty {
                                            // save the new desire
                                            let desire = DesireLM(name: newDesireText, userId: GlobalVars.authentication!.user_id)
                                            newDesireId = appManager.desiresManager.createDesire(desire: desire)
                                        }
                                    }
                                if let desireId = newDesireId {
                                    let accentColor = GlobalVars.userPreferences.getColorOfPriority(3)
                                    EditGoalView(desireId: desireId)
                                        .background(Capsule().fill(accentColor.opacity(0.2)))
                                        .padding(.bottom)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

struct WeekProgressPreview: PreviewProvider {
    static var previews: some View {
        WeekProgressView(GoalAchievingReport(
            startDate: Calendar.current.date(byAdding: DateComponents.init(day:-3), to: Date.now)!,
            endDate: Calendar.current.date(byAdding: DateComponents.init(day:3), to: Date.now)!,
            desires: [DesireLM(desireId: 1, name: "Be a good father", userId: 1, dateCreated: Date.now),
                DesireLM(desireId: 6, name: "Be a good husband", userId: 1, dateCreated: Date.now)],
            goals: [
                GoalLM(goalId:2, desireId: 1, userId: 1, name: "play with the kids", howMuch: 5, startDate: Date.now, deadlineDate: Date.now, priorityLevel: 1),
                GoalLM(goalId: 4, desireId: 1, userId: 1, name: "pray as a family", howMuch: 7, startDate: Date.now, deadlineDate: Date.now, priorityLevel: 2),
                GoalLM(goalId: 7, desireId: 6, userId: 1, name: "Tell my wife I love her", howMuch: 7, startDate: Date.now, deadlineDate: Date.now.addingTimeInterval(60*60*24*2), priorityLevel: 3)],
            todosByGoalId: [2:[]],
            eventsByGoalId: [
                2: [CalendarEventLM(eventId: 3, userId: 1, name: "event", startInstant: Date.now, duration: 1000, linkedGoalId: 2, howMuchAccomplished: 1)],
                4: [CalendarEventLM(eventId:5, userId: 1, name: "something", startInstant: Date.now, duration: 10000, linkedGoalId: 4, howMuchAccomplished: 5)],
                7: [CalendarEventLM(eventId: 8, userId: 1, name: "aoeu", startInstant: Date.now, duration: 2000, linkedGoalId: 7, howMuchAccomplished: 7)]]
        ))
    }
}
