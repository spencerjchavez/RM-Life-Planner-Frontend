//
//  ContentView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    @State private var desiresAndGoalsView: AnyView = AnyView(DesiresAndGoalsView())
    @State private var calendarView: AnyView
    @State private var peopleView = AnyView(DesiresAndGoalsView())
    @State private var settingsView = AnyView(SettingsView())
    @State private var focusedView: AnyView
    
    @StateObject var eventsManager = CalendarEventsManager()

    init() {
        let initialCalendarView = AnyView(CalendarView(isSelected: false))
        _focusedView = State(initialValue: initialCalendarView)
        _calendarView = State(initialValue: initialCalendarView)
    }
    var body: some View {
        focusedView
            .environmentObject(eventsManager)
        Spacer()
        CustomNavView(
            toDesiresAndGoalsView: focusDesiresAndGoalsView,
            toCalendarView: focusCalendarView,
            toPeopleView: focusPeopleView,
            toProfileView: focusProfileView)
    }
    public func focusDesiresAndGoalsView() {
        focusedView = desiresAndGoalsView
    }
    public func focusCalendarView() {
        focusedView = calendarView
    }
    public func focusPeopleView() {
        focusedView = peopleView
    }
    public func focusProfileView() {
        focusedView = settingsView
    }
}

struct ProfileView: View {
    var body: some View{
        Text("This will be the profile and settings section")
    }
}

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
