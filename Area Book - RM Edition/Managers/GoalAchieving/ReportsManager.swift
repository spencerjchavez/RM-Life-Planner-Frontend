//
//  ReportServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/6/23.
//

import Foundation
import SwiftUI

class ReportsManager : ObservableObject {
    
    @Published var reportsById: [Int: GoalAchievingReport] = [:]
    var eventsManager: CalendarEventsManager
    var todosManager: TodosManager
    var desiresManager: DesiresManager
    var goalsManager: GoalsManager
    var desiresSubscriber: Any?
    var goalsSubscriber: Any?
    var todosSubscriber: Any?
    var eventsSubscriber: Any?

    init(eventsManager: CalendarEventsManager, todosManager: TodosManager, desiresManager: DesiresManager, goalsManager: GoalsManager) {
        self.eventsManager = eventsManager
        self.todosManager = todosManager
        self.desiresManager = desiresManager
        self.goalsManager = goalsManager
        
        self.desiresSubscriber = desiresManager.$desiresById.sink(receiveValue: { _ in
            self.recreateReports()
        })
        self.goalsSubscriber = goalsManager.$goalsById.sink(receiveValue: { _ in
            self.recreateReports()
        })
        self.todosSubscriber = todosManager.$todosById.sink(receiveValue: { _ in
            self.recreateReports()
        })
        self.eventsSubscriber = eventsManager.$eventsById.sink(receiveValue: { _ in
            self.recreateReports()
        })
    }
    
    func createReport(startDate: Date, endDate: Date? = nil) -> Int {
        //let startDate = Date.now.addingTimeInterval(-60*60*24*5)
        // endDay is inclusive in report
        let desires = desiresManager.getLocalDesiresOfUser()
        let goals = goalsManager.getLocalGoalsInRange(startDate, endDate)
        let goalIds = goals.map({ goal in
            goal.goalId
        })
        let todos = todosManager.getLocalTodosByGoalIds(goalIds)
        let events = eventsManager.getLocalCalendarEventsByGoalIds(goalIds)
        
        let report = GoalAchievingReport(startDate: startDate, endDate: endDate ?? Date.distantFuture, desires: desires, goals: goals, todosByGoalId: todos, eventsByGoalId: events)
        reportsById[report.id] = report
        return report.id
    }
    
    func getReport(id: Int) -> GoalAchievingReport? {
        return self.reportsById[id]
    }
    
    func createDayReport(date: Date) -> Int? {
        return createReport(startDate: date, endDate: date)
    }
    
    func createWeekReport(startDate: Date) -> Int? {
        let endDate = Calendar.current.date(byAdding: DateComponents(day: 6), to: startDate)
        guard let endDate = endDate else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getWeekReport(startDate)", loggingMessage: "Could not create endDate var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return nil
        }
        return createReport(startDate: startDate, endDate: endDate)
    }
    
    func createMonthReport(startDate: Date) -> Int? {
        let plusOneMonth = Calendar.current.date(byAdding: DateComponents(month:1), to: startDate)
        guard let plusOneMonth = plusOneMonth else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getMonthReport(startDate)", loggingMessage: "Could not create plusOneMonth var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return nil
        }
        let endDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: plusOneMonth)
        guard let endDate = endDate else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getMonthReport(startDate)", loggingMessage: "Could not create endDate var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return nil
        }
        return createReport(startDate: startDate, endDate: endDate)
    }
    
    private func recreateReports() {
        for reportId in reportsById.keys {
            if var report = reportsById[reportId] {
                let newReportId = createReport(startDate: report.startDate, endDate: report.endDate)
                if var report = getReport(id: newReportId) {
                    reportsById.removeValue(forKey: newReportId)
                    report.id = reportId
                    reportsById[reportId] = report
                }
            }
        }
    }
}
