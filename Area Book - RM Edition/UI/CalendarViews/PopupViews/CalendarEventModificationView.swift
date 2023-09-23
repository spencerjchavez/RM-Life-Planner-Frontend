//
//  EditCalendarEventView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/26/23.
//

import SwiftUI

// used to create new calendar events and modify existing ones.
// use its eventId initializer to modify an existing event
struct CalendarEventModificationView: View, Hashable {
    private var event: CalendarEventLM?
    private var recurrenceId: Int?
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    @Binding private var navigationPath: NavigationPath
        
    @State var eventTitle: String
    @State var eventDescription: String
    @State var eventStartInstant: Date
    @State var eventEndInstant: Date
    
    @State var eventRepeatPattern: RRuleComponents.RepeatPattern = .noRepeat
    @State var eventRepeatDays = [false, false, false, false, false, false, false]
    @State var eventRepeatInterval: Int = 1
    
    @State var linkedGoalId: Int? //goalId
    @State var linkedTodoId: Int?
    
    @FocusState var titleIsFocused: Bool
    @FocusState var descriptionIsFocused: Bool
    
    // edit existing event
    init(event: CalendarEventLM, navigationPath: Binding<NavigationPath>) {
        self.event = event
        self._navigationPath = navigationPath
        self.recurrenceId = event.recurrenceId
        self._eventTitle = State(initialValue: event.name)
        self._eventDescription = State(initialValue: event.description ?? "")
        self._eventStartInstant = State(initialValue: event.startInstant)
        self._eventEndInstant = State(initialValue: event.endInstant)
        self._linkedGoalId = State(initialValue: event.linkedGoalId)
        self._linkedTodoId = State(initialValue: event.linkedTodoId)
    }
    // create new event
    init (startInstant: Date, navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
        _eventTitle = State(initialValue: "")
        _eventDescription = State(initialValue: "")
        _eventStartInstant = State(initialValue: startInstant)
        _eventEndInstant = State(initialValue: startInstant + 60*60)
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                HStack {
                    VStack {
                        TextField("Event title", text: $eventTitle)
                            .focused($titleIsFocused)
                            .font(.title)
                            .fontWeight(.black)
                            .padding()
                        TextField("Event description", text: $eventDescription, axis: .vertical)
                            .focused($descriptionIsFocused)
                            .autocorrectionDisabled(true)
                            .font(.subheadline)
                            .padding(.bottom)
                            .padding(.horizontal)
                    }
                }
                .background(
                    in: RoundedRectangle(cornerRadius: 15.0)
                )
                .backgroundStyle(Colors.coolMint)
                .padding(20)
                .onTapGesture {
                    titleIsFocused = false
                    descriptionIsFocused = false
                }
            }
            .onTapGesture {
                titleIsFocused = false
                descriptionIsFocused = false
            }
            
            if(!titleIsFocused && !descriptionIsFocused) {
                DatePicker(
                    "From: ",
                    selection: $eventStartInstant,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding(.horizontal)
                DatePicker(
                    "To: ",
                    selection: $eventEndInstant,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding(.horizontal)
                HStack {
                    Text("Repeats: ")
                    Spacer()
                    VStack {
                        Picker("Repeat Pattern", selection: $eventRepeatPattern) {
                            ForEach(RRuleComponents.RepeatPattern.allCases) { pattern in
                                switch pattern {
                                case .noRepeat:
                                    Text("no repeat")
                                case .repeatsDaily:
                                    Text("daily")
                                case .repeatsWeekly:
                                    Text("weekly")
                                case .repeatsByDayOfMonth:
                                    Text("every \(getDayNumAsStr(date: eventStartInstant)) of the month")
                                case .repeatsByWeekOfMonth:
                                    Text("every \(getNthDayOfWeekStr(date: eventStartInstant)) of the month")
                                case .repeatsYearly:
                                    Text("yearly")
                                case .customRepeat:
                                    Text("custom")
                                }
                            }
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
                .padding(.horizontal)
                HStack {
                    Button(action: cancel){
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    }
                    .background(in: RoundedRectangle(cornerRadius: 15.0))
                    .backgroundStyle(Colors.lightGray)
                    .padding()
                    Button(action: submit){
                        Text("Finish")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    }
                    .background(in: RoundedRectangle(cornerRadius: 15.0))
                    .backgroundStyle(Colors.coolMint)
                    .padding()
                }
                if let eventId = event?.eventId {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13.0)
                            .fill(.red)
                            .opacity(0.6)
                            .onTapGesture {
                                appManager.eventsManager.deleteCalendarEvent(eventId: eventId)
                                delete()
                            }
                            .frame(height: 40)
                        Image(systemName: "trash")
                    }
                    .padding(.horizontal, 15)
                }
            }
            Spacer()
        }
    }
    func getNthDayOfWeekStr(date: Date) -> String{
        let components = Calendar.current.dateComponents([.weekOfMonth], from: date)
        let numStr = components.weekOfMonth!.description + getNumberSuffix(x: components.weekOfMonth!)
        var df = DateFormatter()
        df.dateFormat = "EEEE" //Day of weeek full name
        var dayStr = df.string(from: date)
        return numStr + " " + dayStr
    }
    func getDayNumAsStr(date: Date) -> String {
        let components = Calendar.current.dateComponents([.day], from: date)
        return components.day!.description + getNumberSuffix(x: components.day!)
    }
    func getNumberSuffix(x: Int) -> String {
        var suffix = ""
        let lastDigit = x.description.last!
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
        navigationPath.removeLast()
    }
    func delete() {
        navigationPath.removeLast()
    }
    func submit() {
        // TODO: need to prompt if we edit future recurrences or not...
        if var event = event { // edit existing event
            event.name = eventTitle
            event.description = eventDescription
            event.startInstant = eventStartInstant
            event.endInstant = eventEndInstant
            event.duration = event.startInstant.distance(to: event.endInstant)
            event.linkedGoalId = linkedGoalId
            event.linkedTodoId = linkedTodoId
            event.recurrenceId = recurrenceId
            appManager.eventsManager.updateCalendarEvent(eventId: event.eventId, updatedCalendarEvent: event)
            navigationPath.removeLast() // removes self from navigation stack, popping us back to the previous view
        } else { //create new event
            if eventRepeatPattern != .noRepeat {
                // create new recurrence
                // TODO: make it possible to add end dates to recurrences
                let rrule = RRuleComponents(pattern: eventRepeatPattern, startDate: eventStartInstant, endDate: nil, interval: eventRepeatInterval).toEKRecurrenceRule()
                let recurrence = RecurrenceLM(userId: GlobalVars.authentication!.user_id, rrule: rrule, startInstant: eventStartInstant, eventName: eventTitle, eventDescription: eventDescription, eventDuration: eventStartInstant.distance(to: eventEndInstant))
                appManager.recurrenceManager.create(recurrence)
                // invalidate recurrence days to trigger reloading from server
                appManager.eventsManager.invalidateEventsAfterDate(after: eventStartInstant)
            } else {
                let event = CalendarEventLM(userId: GlobalVars.authentication!.user_id, name: eventTitle, description: eventDescription, startInstant: eventStartInstant, endInstant: eventEndInstant, linkedGoalId: linkedGoalId, linkedTodoId: linkedTodoId)
                appManager.eventsManager.createCalendarEvent(event: event)
                navigationPath.removeLast()
            }
        }
    }
    static func == (lhs: CalendarEventModificationView, rhs: CalendarEventModificationView) -> Bool {
        return lhs.event?.eventId == rhs.event?.eventId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(event?.eventId)
    }
}
