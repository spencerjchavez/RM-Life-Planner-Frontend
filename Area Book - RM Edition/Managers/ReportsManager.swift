//
//  ReportServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/6/23.
//

import Foundation
import SwiftUI

class ReportsManager {
    
    @EnvironmentObject var appManager: RMLifePlannerManager

    func getReport(startDate: Date, endDate: Date) async -> GoalAchievingReport {
        // endDay is inclusive in report
        async let desires = appManager.desiresManager.getDesiresOfUser()
        async let goals = appManager.goalsManager.getGoalsInRange(startDate, endDate)
        let goalIds = await goals.map({ goal in
            goal.goalId
        })
        let getTodosTask = Task {
            let todos = await appManager.todosManager.getTodosByGoalIds(goalIds)
            return todos
        }
        let getEventsTask = Task {
            let events = await appManager.eventsManager.getCalendarEventsByGoalIds(goalIds)
            return events
        }
        return await GoalAchievingReport(startDate: startDate, endDate: endDate, desires: desires, goals: goals, todosByGoalId: getTodosTask.value, eventsByGoalId: getEventsTask.value)
    }
    func getDayReport(date: Date) async -> GoalAchievingReport {
        return await getReport(startDate: date, endDate: date)
    }
    func getWeekReport(startDate: Date) async -> GoalAchievingReport {
        let endDate = Calendar.current.date(byAdding: DateComponents(day: 6), to: startDate)
        guard let endDate = endDate else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getWeekReport(startDate)", loggingMessage: "Could not create endDate var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return GoalAchievingReport(startDate: startDate, endDate: startDate, desires: [], goals: [], todosByGoalId: [:], eventsByGoalId: [:])
        }
        return await getReport(startDate: startDate, endDate: endDate)
    }
    func getMonthReport(startDate: Date) async -> GoalAchievingReport {
        let plusOneMonth = Calendar.current.date(byAdding: DateComponents(month:1), to: startDate)
        guard let plusOneMonth = plusOneMonth else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getMonthReport(startDate)", loggingMessage: "Could not create plusOneMonth var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return GoalAchievingReport(startDate: startDate, endDate: startDate, desires: [], goals: [], todosByGoalId: [:], eventsByGoalId: [:])
        }
        let endDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: plusOneMonth)
        guard let endDate = endDate else {
            ErrorManager.reportError(throwingFunction: "ReportsManager.getMonthReport(startDate)", loggingMessage: "Could not create endDate var with startDate: \(startDate)", messageToUser: "Could not get report at this time")
            return GoalAchievingReport(startDate: startDate, endDate: startDate, desires: [], goals: [], todosByGoalId: [:], eventsByGoalId: [:])
        }
        return await getReport(startDate: startDate, endDate: endDate)
    }
}
