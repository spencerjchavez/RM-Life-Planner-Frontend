//
//  DesiresAndGoalsProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct GeneralProgressView: View{
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    @State var navigationPath = NavigationPath()
    let report: GoalAchievingReport
    
    init() {
        self.report = GoalAchievingReport(
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
    }
    
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            GeometryReader { reader in
                ZStack {
                    WeekProgressView(self.report)
                    VStack {
                        Spacer()
                            HStack {
                                Spacer()
                                VStack (alignment: .trailing) {
                                    Button {
                                        // new desire button
                                        navigationPath.append(NavTypes.desire)
                                    } label: {
                                        Text("Add or Edit Long-Term Goals")
                                            .fontWeight(.semibold)
                                            .foregroundColor(Colors.backgroundWhite)
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 20).fill(Colors.accentColorLight))
                                }.padding(.trailing)
                            }
                        }
                        HStack {
                            Spacer()
                            Button{
                                // open up prompt to create new priority or goal
                                promptCreateNew.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding()
                                    .frame(maxWidth: reader.size.width/7, maxHeight: reader.size.width/7)
                                    .background(Circle().fill(Colors.accentColorLight))
                                    .foregroundColor(Colors.backgroundWhite)
                            }
                            .padding(.trailing)
                            .padding(.bottom)


                        }
                        Text("Your Priorities")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.textSubtitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Rectangle().fill(Colors.backgroundOffWhite))
                    }
                }.navigationDestination(for: NavTypes.self, destination: { type in
                    if type == .desire {
                        EditDesiresView(navigationPath: $navigationPath)
                    } else {
                        CreateGoalView(navigationPath: $navigationPath)
                    }
                })
            }
        }
    }
    enum NavTypes {
        case desire
        case goal
    }
}
struct GeneralProgressViewPreview: PreviewProvider {
    static var previews: some View {
        GeneralProgressView()
    }
}
