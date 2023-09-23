//
//  ContentView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appManager = RMLifePlannerManager()

    @State private var desiresAndGoalsView: AnyView
    @State private var calendarView: AnyView
    @State private var peopleView: AnyView
    @State private var settingsView: AnyView
    @State private var focusedView: AnyView

    init() {
        let initialCalendarView = AnyView(CalendarView())
        _focusedView = State(initialValue: initialCalendarView)
        _calendarView = State(initialValue: initialCalendarView)
        _settingsView = State(initialValue: AnyView(SettingsView()))
        _peopleView = State(initialValue: AnyView(SettingsView()))
        _desiresAndGoalsView = State(initialValue: AnyView(MainProgressView()))
    }
    var body: some View {
        VStack {
            focusedView
            Spacer()
            CustomNavView(
                toDesiresAndGoalsView: focusDesiresAndGoalsView,
                toCalendarView: focusCalendarView,
                toPeopleView: focusPeopleView,
                toProfileView: focusProfileView)
        }
        .environmentObject(appManager)

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
