//
//  RMLifePlannerManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/7/23.
//

import Foundation

class RMLifePlannerManager: ObservableObject {
    var authenticationSubscriber: Any? = nil
    
    @Published var eventsManager: CalendarEventsManager
    @Published var todosManager: TodosManager
    @Published var desiresManager: DesiresManager
    @Published var goalsManager: GoalsManager
    @Published var reportsManager: ReportsManager
    @Published var authentication: Authentication? = nil
    @Published var userPreferences: UserPreferencesLM? = nil
    var recurrenceManager: RecurrencesManager
    
    init(eventsManager: CalendarEventsManager = CalendarEventsManager(), todosManager: TodosManager = TodosManager(), desiresManager: DesiresManager = DesiresManager(), goalsManager: GoalsManager = GoalsManager(), recurrenceManager: RecurrencesManager = RecurrencesManager()) {
        self.eventsManager = eventsManager
        self.todosManager = todosManager
        self.desiresManager = desiresManager
        self.goalsManager = goalsManager
        self.recurrenceManager = recurrenceManager
        self.reportsManager = ReportsManager(eventsManager: eventsManager, todosManager: todosManager, desiresManager: desiresManager, goalsManager: goalsManager)
        authenticationSubscriber = self._authentication.projectedValue.sink{ authentication in
            if let authentication = authentication {
                self.eventsManager.authentication = authentication
                self.todosManager.authentication = authentication
                self.desiresManager.authentication = authentication
                self.goalsManager.authentication = authentication
                self.recurrenceManager.authentication = authentication
            }
        }
    }
}
