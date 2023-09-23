//
//  DesiresAndGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct GoalAchievingReportWeekView: View {
    var report: GoalAchievingReport
    var startDate: Date
    var endDate: Date
    var startDateFormatted: String
    var endDateFormatted: String
        
    init(report: GoalAchievingReport) {
        self.report = report
        self.startDate = report.startDate
        self.endDate = report.endDate
        self.startDateFormatted = startDate.formatted(date: .numeric, time: .omitted)
        self.endDateFormatted = endDate.formatted(date: .numeric, time: .omitted)
    }
    
    var body: some View {
        ScrollView(){
            VStack(alignment: .center) {
                Text("week of \(startDateFormatted) - \(endDateFormatted)")
                    .foregroundColor(.black)
                    .font(.title)
                DesirePieChart(report: report)
                Text("Your Desires:")
                    .font(.title2)
                ForEach(report.desires, id: \.self) { desire in
                    HStack {
                        Rectangle()
                            .fill(GlobalVars.userPreferences!.getColorOfPriority(desire.priorityLevel))
                            .aspectRatio(1.0, contentMode: .fit)
                            .fixedSize()
                        Text(Int((report.desiresProgress[desire.desireId]! * 100).rounded()).description + "% - " + desire.name)
                        Spacer()
                    }
                    .font(.body)
                    .fixedSize()
                }
            }
            .padding()
        }
    }
}
