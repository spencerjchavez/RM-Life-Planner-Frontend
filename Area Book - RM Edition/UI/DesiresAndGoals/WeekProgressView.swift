//
//  WeekProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 1/11/24.
//

import SwiftUI

struct WeekProgressView: View {
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    @State var navigationPath: [GoalAchievingNavigationItem] = []
    @State var createNewDesire: Bool = false
    var report: GoalAchievingReport
    
    init(_ report: GoalAchievingReport) {
        self.report = report
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ScrollView {
                    ScrollViewReader { reader in
                        VStack (spacing: 0) {
                            // display holistic progress
                            Text("\(Int((report.totalProgress*100).rounded()))% Done - You've Got This!")
                                .font(.title2)
                                .fontWeight(.light)
                                .frame(maxWidth: .infinity)
                                .background(Colors.backgroundOffWhite)
                                .foregroundColor(Colors.textBody)
                                .padding(.bottom)
                            
                            VStack(alignment: .leading){
                                // display individual desires + goals
                                ForEach(self.report.desires, id: \.self) { desire in
                                    // display desire
                                    VStack {
                                        HStack {
                                            Text(desire.name.capitalized)
                                                .fontWeight(.semibold)
                                                .font(.title2)
                                                .foregroundColor(Colors.textSubtitle)
                                                .onTapGesture {
                                                    navigationPath.append(GoalAchievingNavigationItem(viewType: .editDesire, desire: desire))
                                                }
                                            Spacer()
                                        }
                                        // display goals
                                        DisplayGoals(goals: self.report.goalsByDesireId[desire.desireId] ?? [], desire: desire, report: self.report, navigationPath: $navigationPath)
                                        HStack {
                                            Button {
                                                // add new goal
                                                navigationPath.append(GoalAchievingNavigationItem(viewType: .createGoal, desire: desire))
                                            } label: {
                                                Text("New Sub-Goal")
                                                    .foregroundStyle(Colors.textBody)
                                                    .padding()
                                                    .background(RoundedRectangle(cornerRadius: 15).fill(Colors.backgroundOffWhite))
                                                    .padding(.leading)
                                            }
                                            Spacer()
                                        }
                                        Divider()
                                            .frame(maxWidth: .infinity, maxHeight: 4)
                                            .foregroundStyle(Colors.backgroundOffWhite)
                                    }
                                    .padding(7)
                                }
                                // add prompt to create a new desire here
                                HStack {
                                    Button {
                                        navigationPath.append(GoalAchievingNavigationItem(viewType: .createDesire))
                                    } label: {
                                        Text(self.report.desires.count > 0 ? "Create New Long-Term Goal" : "Create Your First Long-Term Goal")
                                            .fontWeight(.medium)
                                            .font(.title3)
                                            .foregroundStyle(Colors.textBody)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 15).fill(Colors.backgroundOffWhite))
                                            .padding()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }       
            .navigationDestination(for: GoalAchievingNavigationItem.self, destination: { navigationItem in
                if navigationItem.viewType == .editDesire {
                    if let desire = navigationItem.desire {
                        EditDesireView(desire: desire, navigationPath: self.$navigationPath)
                    }
                } else if navigationItem.viewType == .editGoal {
                    if let desire = navigationItem.desire, let goal = navigationItem.goal {
                        EditGoalView(desire: desire, goal: goal, todos: report.todosByGoalId[goal.goalId] ?? [], navigationPath: $navigationPath)
                    }
                } else if navigationItem.viewType == .createDesire {
                    AddDesireView(navigationPath: $navigationPath, authentication: appManager.authentication!)
                } else if navigationItem.viewType == .createGoal {
                    if let desire = navigationItem.desire {
                        EditGoalView(desire: desire, navigationPath: $navigationPath)
                    }
                }
            })
        }
    }
        
    struct DisplayGoals: View {
        @EnvironmentObject var appManager: RMLifePlannerManager
        @Binding var navigationPath: [GoalAchievingNavigationItem]
        let goals: [GoalLM]
        let report: GoalAchievingReport
        let desire: DesireLM
        
        init(goals: [GoalLM], desire: DesireLM, report: GoalAchievingReport, navigationPath: Binding<[GoalAchievingNavigationItem]>) {
            self.report = report
            self._navigationPath = navigationPath
            self.goals = goals
            self.desire = desire
        }
        var body: some View {
            VStack (spacing: 10) {
                ForEach(goals, id: \.self) { goal in
                    let amountAccomplished = report.goalsHowMuchAccomplished[goal.goalId] ?? 0.0
                    let color = appManager.userPreferences!.getColorOfPriority(goal.priorityLevel)
                    GoalProgressView(goal: goal, amountAccomplished: amountAccomplished, accentColor: color, backgroundColor: Colors.backgroundOffWhite)
                        .background(Capsule().fill(color.opacity(0.5)))
                        .onTapGesture {
                            navigationPath.append(GoalAchievingNavigationItem(viewType: .editGoal, desire: desire, goal: goal))
                        }
                }
            }
        }
    }
    
    
    struct EditDesireView: View {
        @EnvironmentObject var appManager: RMLifePlannerManager
        @State var desire: DesireLM
        @Binding var navigationPath: [GoalAchievingNavigationItem]
        
        init(desire: DesireLM, navigationPath: Binding<[GoalAchievingNavigationItem]>) {
            self._desire = State(initialValue: desire)
            self._navigationPath = navigationPath
        }
        
        var body: some View {
            VStack {
                TextField("Enter a Long-Term Goal", text: $desire.name)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    .lineLimit(1)
                    .fontWeight(.medium)
                    .padding()
                HStack {
                    // delete button
                    Button {
                        //self.appManager.goalsManager.deleteGoalsWithDesireId(desire.desireId)
                        self.appManager.desiresManager.deleteDesire(desireId: desire.desireId)
                        navigationPath.removeLast()
                        
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.7)))
                    }
                    // cancel button
                    Button {
                        self.desire.name = appManager.desiresManager.getDesire(desireId: desire.desireId)?.name ?? ""
                        navigationPath.removeLast()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Colors.backgroundOffWhite))
                    }.padding()
                    // save changes button
                    Button {
                        appManager.desiresManager.updateDesire(desireId: self.desire.desireId, updatedDesire: self.desire)
                        navigationPath.removeLast()
                        
                    } label: {
                        Text("Save Long-Term Goal")
                            .foregroundStyle(Colors.textBody)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Colors.accentColorLight))
                    }
                }
            }
        }
    }
    
    struct AddDesireView : View {
        @EnvironmentObject var appManager: RMLifePlannerManager
        @State var newDesire: DesireLM
        @Binding var navigationPath: [GoalAchievingNavigationItem]
        
        init(navigationPath: Binding<[GoalAchievingNavigationItem]>, authentication: Authentication) {
            self._navigationPath = navigationPath
            newDesire = DesireLM(name: "", userId: authentication.user_id, dateCreated: Date.now)
        }
        
        var body: some View {
            VStack (alignment: .center) {
                TextField("Enter A New Long-Term Goal", text: $newDesire.name)
                    .fontWeight(.semibold)
                    .font(.title2)
                    .foregroundColor(Colors.textSubtitle)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                Button {
                    // save the new desire
                    _ = appManager.desiresManager.createDesire(desire: newDesire)
                    self.navigationPath.removeLast()
                    self.navigationPath.append(GoalAchievingNavigationItem(viewType: .createGoal, desire: newDesire))
                } label: {
                    Text("Save Long-Term Goal")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Colors.accentColorLight))
                }
            }
        }
    }
}

struct WeekProgressPreview: PreviewProvider {
    static var previews: some View {
        @State var report = GoalAchievingReport(
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
        )
        WeekProgressView(report)
    }
}
