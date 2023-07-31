//
//  EditCalendarEventView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/26/23.
//

import SwiftUI

struct EditCalendarEventView: View {
    
    var eventId: Int
    @EnvironmentObject var eventsManager: CalendarEventsManager
    var goals: [Goal]
    var desires: [Desire]
    
    
    @State var eventTitle: String
    @State var eventDescription: String
    @State var eventStartDate: Date
    @State var eventEndDate: Date
    
    @State var eventRepeatPattern: Recurrence.RepeatPattern?
    @State var eventRepeatDays = [false, false, false, false, false, false, false]
    @State var eventRepeatInterval: Int = 1
    
    @State var linkedGoalId: Int //goalId
    
    init() {
        
    }
    
    var body: some View {
        VStack {
            TextField(
                "Event title",
                text: $eventTitle
            )
            .autocorrectionDisabled(true)
            HStack {
                //start and end times
                Text("From: ")
                Text(eventStartDate.formatted(date: .omitted, time: .shortened))
                if eventStartDate.formatted(date: .numeric, time: .omitted) != eventEndDate.formatted(date: .numeric, time: .omitted) {
                    //if start and end days are different
                    Text(eventStartDate.formatted(date: .abbreviated, time: .omitted))
                }
                Text("to: ")
                Text(eventEndDate.formatted(date: .omitted, time: .shortened))
                Text(eventEndDate.formatted(date: .abbreviated, time: .omitted))
            }
            HStack {
                Text("Repeats: ")
                VStack {
                    Picker("Repeat Pattern", selection: $eventRepeatPattern) {
                        /*ForEach(Recurrence.RepeatPattern.allCases) { pattern in
                            switch pattern {
                            case .noRepeat:
                                Text("does not repeat")
                            case .repeatsDaily:
                                Text("daily")
                            case .repeatsWeekly:
                                Text("weekly")
                            case .repeatsByDayOfMonth:
                                let components = Calendar.current.dateComponents([.day], from: eventStartDate)
                                let numStr = components.day!.description + getNumberSuffix(x: components.day)
                                Text("every \(numStr) of the month")
                            case .repeatsByWeekOfMonth:
                                let components = Calendar.current.dateComponents([.weekOfMonth], from: eventStartDate)
                                let numStr = components.weekOfMonth!.description + getNumberSuffix(x: components.weekOfMonth)

                                var df = DateFormatter()
                                df.dateFormat = "EEEE" //Day of weeek full name
                                var dayStr = df.string(from: eventStartDate)
                                
                                Text("every \(numStr) \(dayStr) of the month")
                            case .repeatsYearly:
                                Text("yearly")
                            case .customRepeat:
                                Text("custom")
                            }
                        }*/
                    }.pickerStyle(.menu)
                    if eventRepeatPattern == .customRepeat {
                        VStack {
                            HStack {
                                Toggle(isOn: $eventRepeatDays[0]) {Text("Sunday")}
                                Toggle(isOn: $eventRepeatDays[1]) {Text("Monday")}
                                Toggle(isOn: $eventRepeatDays[2]) {Text("Tuesday")}
                                Toggle(isOn: $eventRepeatDays[3]) {Text("Wednesday")}
                                Toggle(isOn: $eventRepeatDays[4]) {Text("Thursday")}
                                Toggle(isOn: $eventRepeatDays[5]) {Text("Friday")}
                                Toggle(isOn: $eventRepeatDays[6]) {Text("Saturday")}
                                
                            }
                            HStack {
                                Text("every ")
                                Picker("week interval", selection: $eventRepeatInterval) {
                                    ForEach(1..<7) { x in
                                        Text(x.description)
                                    }
                                }
                                Text(" weeks")
                            }
                        }
                    }
                }
            }
            HStack {
                Button(action: cancel){
                    Text("cancel")
                }
                Button(action: submit){
                    Text("Done")
                }
            }
        }
    }
    func getNumberSuffix(x: Int) -> String {
        var suffix = ""
        var lastDigit = x.description.last!
        switch lastDigit {
        case "1":
            suffix = "st"
        case "2":
            suffix = "nd"
        case "3":
            suffix = "rd"
        default:
            suffix = "th"
        }
        return suffix
    }
    func cancel() {
        
    }
    func submit() {
        let event = CalendarEvent(eventId: eventId, usedId: userId, name: eventTitle, description: eventDescription, startInstant: eventStartDate.timeIntervalSince1970, endInstant: eventEndDate.timeIntervalSince1970, linkedGoalId: linkedGoalId, linkedTodoId: linkedTodoId, recurrenceId: recurrenceId)
        Task(operation: {
            await eventsManager.addEvent(event: event)
        })
    }
}
