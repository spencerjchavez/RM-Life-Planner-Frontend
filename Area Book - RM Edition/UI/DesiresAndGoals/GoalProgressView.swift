//
//  GoalProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct GoalProgressView: View {
    
    var goal: GoalLM
    var amountAccomplished: Double
    var accentColor: Color
    var backgroundColor: Color

    init(goal: GoalLM, amountAccomplished: Double, accentColor: Color, backgroundColor: Color) {
        self.goal = goal
        self.amountAccomplished = amountAccomplished
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack (spacing: 0) {
            CircularProgressView(amountAccomplished: self.amountAccomplished,
                                 amountPlanned: self.goal.howMuch,
                                 accentColor: self.accentColor,
                                 backgroundColor: self.backgroundColor)
            .padding()
            // display percentage completed
            Text("\(Int((100 * amountAccomplished / goal.howMuch).rounded()))%")
                .fontWeight(.bold)
                .font(.body)
            //display goal text
            Text(goal.name.lowercased().replacingOccurrences(of: "i ", with: "I "))
                .font(.body)
                .padding(.leading, 5)
            Spacer(minLength: 0)
            Divider()
            VStack {
                Text("Deadline:")
                DeadlineText(self.goal.deadlineDate)
            }
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(5, contentMode: .fit)
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
                    self.text = "Today"
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
                self.text = "None"
                return
            }
        }
        
        var body: some View {
            Text("\(text)")
        }

    }
}

/*struct GoalProgressViewPreview: PreviewProvider {
    static var previews: some View {
        GoalProgressView(<#T##GoalLM#>, amountAccomplished: <#T##Double#>, amountPlanned: <#T##Double#>, accentColor: <#T##Color#>, backgroundColor: <#T##Color#>)
    }
}*/
