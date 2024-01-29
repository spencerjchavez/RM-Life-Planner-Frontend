//
//  GoalProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct GoalProgressView: View {
    
    var goalName: String
    var amountAccomplished: Double
    var amountPlanned: Double
    var deadlineDate: Date?
    var accentColor: Color
    var backgroundColor: Color

    init(goalName: String, amountAccomplished: Double, amountPlanned: Double, deadlineDate: Date?, accentColor: Color, backgroundColor: Color) {
        self.goalName = goalName
        self.amountAccomplished = amountAccomplished
        self.amountPlanned = amountPlanned
        self.deadlineDate = deadlineDate
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack {
            CircularProgressView(amountAccomplished: self.amountAccomplished,
                                 amountPlanned: self.amountPlanned,
                                 accentColor: self.accentColor,
                                 backgroundColor: self.backgroundColor)
            .padding()
            // display percentage completed
            Text("\(Int((100 * amountAccomplished / amountPlanned).rounded()))%")
                .fontWeight(.bold)
                .font(.body)
            //display goal text
            Spacer(minLength: 0)
            Text(goalName.lowercased().replacingOccurrences(of: "i ", with: "I "))
                .font(.body)
                .padding(3)
            Spacer(minLength: 0)
            Divider()
            VStack {
                Text("Deadline:")
                DeadlineText(self.deadlineDate)
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
