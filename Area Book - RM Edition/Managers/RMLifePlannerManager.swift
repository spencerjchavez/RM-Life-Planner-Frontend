//
//  RMLifePlannerManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/7/23.
//

import Foundation

class RMLifePlannerManager: ObservableObject {
    @Published var eventsManager = CalendarEventsManager()
    @Published var todosManager = TodosManager()
    @Published var desiresManager = DesiresManager()
    @Published var goalsManager = GoalsManager()
    var recurrenceManager = RecurrencesManager()
}
