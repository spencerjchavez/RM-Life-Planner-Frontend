//
//  WeekProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 1/11/24.
//

import SwiftUI

struct WeekProgressView: View {
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    let reportsManager = ReportsManager()
    var report: GoalAchievingReport
    
    init(_ report: GoalAchievingReport) {
        self.report = report
    }
    
    var body: some View {
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
                    
                    // display individual desires + goals
                    ForEach(report.desires, id: \.self) { desire in
                        Text(desire.name.capitalized)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .foregroundColor(Colors.textSubtitle)
                            .frame(maxWidth: .infinity)
                        VStack (spacing: 0) {
                            ForEach(report.goalsByDesireId[desire.desireId] ?? [], id: \.self) { goal in
                                let amountAccomplished = report.goalsHowMuchAccomplished[goal.goalId] ?? 0.0
                                let amountPlanned = report.goalsHowMuchPlanned[goal.goalId] ?? 0.0
                                let color = GlobalVars.userPreferences.getColorOfPriority(goal.priorityLevel)
                                HStack {
                                    CircularProgressView(amountAccomplished: amountAccomplished,
                                                         amountPlanned: amountPlanned,
                                                         accentColor: color,
                                                         backgroundColor: Colors.backgroundWhite)
                                    .padding()
                                    // display percentage completed
                                    Text("\(Int((100 * amountAccomplished / amountPlanned).rounded()))%")
                                        .fontWeight(.bold)
                                        .font(.body)
                                    //display goal text
                                    Spacer(minLength: 0)
                                    Text(goal.name.lowercased().replacingOccurrences(of: "i ", with: "I "))
                                        .font(.body)
                                        .padding(3)
                                    Spacer(minLength: 0)
                                    Divider()
                                    VStack {
                                        Text("Deadline:")
                                        DeadlineText(goal.deadlineDate)
                                    }
                                    .padding(.trailing)
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(5, contentMode: .fit)
                                .background(Capsule().fill(color.opacity(0.2)))
                                .padding(.bottom)
                            }
                        }
                    }
                }
                .background(Colors.backgroundWhite)
                .onAppear {
                    Task {
                        //report = await reportsManager.getWeekReport(startDate: Date.now)
                    }
                }
            }
        }
    }
    struct DeadlineText: View {
        let date: Date?
        let text: String
        
        init(_ date: Date?) {
            self.date = date
            if var date = date {
                date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
                let formatter = DateFormatter()
                let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date.now) ?? Date.now
                let aWeekFromNow = Calendar.current.date(byAdding: DateComponents(day: 7), to: today) ?? Date.distantPast
                if date < today {
                    // deadline already passed
                    // put date in numeric format
                    formatter.dateFormat = "M/d"
                } else if self.date == today {
                    self.text = "today"
                    return
                } else if date < aWeekFromNow {
                    // date is within a week, so just use day of week
                    formatter.dateFormat = "E"
                } else {
                    // date is farther than a week out, so use full date
                    formatter.dateFormat = "dddd"
                }
                self.text = formatter.string(from: date)
            } else {
                self.text = "never"
                return
            }
        }
        
        var body: some View {
            Text("\(text)")
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
