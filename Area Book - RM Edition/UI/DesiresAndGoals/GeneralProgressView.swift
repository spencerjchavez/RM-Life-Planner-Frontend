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
    @State var report: GoalAchievingReport?
    @State private var reportsSubscriber: Any? = nil

    init(_ report: GoalAchievingReport? = nil) {
        self._report = State(initialValue: report)
    }
    
    var body: some View {
        VStack {
            if let report = report {
                WeekProgressView(report)
            }
            Spacer()
            Text("Your Goals")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Colors.textSubtitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Rectangle().fill(Colors.backgroundOffWhite))
            
        }.onAppear {
            if let weekend = Calendar.current.nextWeekend(startingAfter: Date.now, direction: .backward) {
                let startDate = Calendar.current.startOfDay(for: weekend.end)
                if let reportId = appManager.reportsManager.createWeekReport(startDate: startDate) {
                    report = appManager.reportsManager.getReport(id: reportId)
                }
            }
            reportsSubscriber = appManager.reportsManager.$reportsById.sink(receiveValue: { reportsById in
                if let report = self.report {
                    self.report = reportsById[report.id]
                }
            })
        }
    }
}
struct GeneralProgressViewPreview: PreviewProvider {
    static var previews: some View {
        @StateObject var appManager: RMLifePlannerManager = RMLifePlannerManager()
        let userId = 1
        
        let report = GoalAchievingReport(
            startDate: Calendar.current.date(byAdding: DateComponents.init(day:-3), to: Date.now)!,
            endDate: Calendar.current.date(byAdding: DateComponents.init(day:3), to: Date.now)!,
            desires: [DesireLM(desireId: 1, name: "Be a good father", userId: userId, dateCreated: Date.now),
                      DesireLM(desireId: 2, name: "Be a good husband", userId: userId, dateCreated: Date.now)],
            goals: [GoalLM(goalId: 3, desireId: 1, userId: userId, name: "play with the kids", howMuch: 5, startDate: Date.now, deadlineDate: Date.now, priorityLevel: 1),
                    GoalLM(goalId: 4, desireId: 1, userId: userId, name: "pray as a family", howMuch: 7, startDate: Date.now, deadlineDate: Date.now, priorityLevel: 2),
                    GoalLM(goalId: 5, desireId: 2, userId: userId, name: "Tell my wife I love her", howMuch: 7, startDate: Date.now, deadlineDate: Date.now.addingTimeInterval(60*60*24*2), priorityLevel: 3)],
            todosByGoalId: [:],
            eventsByGoalId: [
                3: [CalendarEventLM(eventId: 3, userId: 1, name: "event", startInstant: Date.now, duration: 1000, linkedGoalId: 3, howMuchAccomplished: 1)],
                4: [CalendarEventLM(eventId:5, userId: 1, name: "something", startInstant: Date.now, duration: 10000, linkedGoalId: 4, howMuchAccomplished: 5)],
                5: [CalendarEventLM(eventId: 8, userId: 1, name: "aoeu", startInstant: Date.now, duration: 2000, linkedGoalId: 5, howMuchAccomplished: 7)]])
        
        GeneralProgressView(report)
    }
}
