//
//  GoalsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class GoalsManager : ObservableObject {
    
    @Published private var goalsById: [Int: GoalLM] = [:]
    @Published private var goalIdsByDate: [Date: [Int]] = [:]
    static var activeTasksByGoalId: [Int: Task<Void, Never>] = [:]
    static var activeTasksByDate: [Date: Task<Void, Never>] = [:]
    
    func createGoal(goal: GoalLM) -> Int {
        let FUNC_NAME = "GoalsManager.createGoal(goal)"
        guard goalsById[goal.goalId] == nil else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to create goal with id \(goal.goalId), but goal of that id already exists", messageToUser: "Error encountered while adding goal, please try again later.")
            return goal.goalId
        }
        goalsById[goal.goalId] = goal
        addToGoalIdsByDate(goal)
        let toAwait = DesiresManager.activeTasksByDesireId[goal.desireId] // must await creation of the desire first
        GoalsManager.activeTasksByGoalId[goal.goalId] = Task {
            do {
                await toAwait?.value
                let goalSM = try GoalSM(from: goal)
                let serverSideId = try await GoalServices.create(goalSM)
                IdsManager.associateServerId(serverSideId: serverSideId, with: goal.goalId, modelType: GoalLM.getModelName())
            } catch RMLifePlannerError.serverError(let message){
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while adding goalId \(goal.goalId)", messageToUser: "Error encountered while adding goal, please try again later.")
                goalsById[goal.goalId] = nil
            } catch {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating goal", messageToUser: "Error encountered while adding goal, please try again later.")
                goalsById[goal.goalId] = nil
            }
        }
        return goal.goalId
    }
    
    func getGoal(goalId: Int) -> GoalLM? {
        let FUNC_NAME = "GoalsManager.getGoal(goalId)"
        if let goal = goalsById[goalId] {
            return goal
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Failed to get goal with id: \(goalId)", messageToUser: "Error encountered while getting goal, please try again later.")
        }
        return nil
    }
    
    func getLocalGoalsOnDate(_ date: Date) -> [GoalLM] {
        return getLocalGoalsOnDates([date])[date] ?? []
    }
    
    func getLocalGoalsInRange(_ startDate: Date, _ endDate: Date) -> [GoalLM] {
        let FUNC_NAME = "GoalsManager.getLocalGoalsInRange(startDate, endDate)"
        do {
            let dates = try DateHelper.getDatesInRange(startDate: startDate, endDate: endDate)
            let goalsDict = getLocalGoalsOnDates(dates)
            var goalsSet = Set<GoalLM>()
            for goalList in goalsDict.values {
                for goal in goalList {
                    goalsSet.insert(goal)
                }
            }
            return Array(goalsSet)
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to retrieve in dates of invalid range \(startDate) to \(endDate)", messageToUser: "Error encountered. Please try again")
        }
        return []
    }
    
    func getLocalGoalsOnDates(_ dates: [Date]) -> [Date: [GoalLM]] {
        let FUNC_NAME = "GoalsManager(getLocalGoalsOnDates(dates)"
        var toReturn: [Date: [GoalLM]] = [:]
        var datesToFetchFromServer: [Date] = []
        for date in dates {
            toReturn[date] = []
            if let goalIds = goalIdsByDate[date] {
                for goalId in goalIds {
                    if let goal = goalsById[goalId] {
                        toReturn[date]!.append(goal)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state. goal id exists in goalIdsByDate but not in goalsById", messageToUser: "Error in retrieving goals, please try again later")
                    }
                }
            } else {
                // add date to list to fetch from server async
                datesToFetchFromServer.append(date)
            }
        }
        if datesToFetchFromServer.isEmpty {
            return toReturn
        }
        let datesToFetch = datesToFetchFromServer
        Task {
            _ = await getGoalsOnDates(datesToFetch)
        }
        return toReturn
    }
    
    func getGoalsInRange(_ startDate: Date, _ endDate: Date) async -> [GoalLM] {
        do {
            let goalSMs = try await GoalServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), SQLDateFormatter.toSQLDateString(endDate))
            var toReturn: [GoalLM] = []
            for goalSM in goalSMs {
                let goalLM = try GoalLM(from: goalSM)
                addToGoalIdsByDate(goalLM)
                toReturn.append(goalLM)
            }
            return toReturn
        } catch {
            ErrorManager.reportError(throwingFunction: "GoalsManager.getGoalsInRange(startDate, endDate)", loggingMessage: "Error received while attempting to retrieve goals in range \(startDate) to \(endDate)", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        return []
    }
    
    func getGoalsOnDates(_ dates: [Date]) async -> [Date: [GoalLM]] {
        do {
            let dateStrs = dates.map({ date in
                SQLDateFormatter.toSQLDateString(date)
            })
            var toReturn: [Date: [GoalLM]] = [:]
            let goalsSMByDate = try await GoalServices.getByDates(dateStrs)
            for date in dates {
                goalIdsByDate[date] = []
                toReturn[date] = []
                if let goalSms = goalsSMByDate[SQLDateFormatter.toSQLDateString(date)] {
                    for goalSm in goalSms {
                        let goalLM = try GoalLM(from: goalSm)
                        goalsById[goalLM.goalId] = goalLM
                        goalIdsByDate[date]?.append(goalLM.goalId)
                        toReturn[date]?.append(goalLM)
                    }
                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message) {
            ErrorManager.reportError(throwingFunction: "GoalsManager.getGoalsOnDates(dates)", loggingMessage: "received error from server with message: \(message)", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        catch {
            ErrorManager.reportError(throwingFunction: "GoalsManager.getGoalsOnDates(dates)", loggingMessage: "Unknown error received while attempting to retrieve goals", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        return [:]
    }
    
    func updateGoal(goalId: Int, updatedGoal: GoalLM) {
        let FUNC_NAME = "GoalsManager.updateGoal(goalId, updatedGoal)"
        let taskToAwait = GoalsManager.activeTasksByGoalId[goalId]
        if let oldGoal = goalsById[goalId] {
            goalsById[goalId] = updatedGoal
            if oldGoal.startDate != updatedGoal.startDate || oldGoal.deadlineDate != updatedGoal.deadlineDate {
                // need to change goalIDsByDate
                removeFromGoalIdsByDate(oldGoal)
                addToGoalIdsByDate(updatedGoal)
            }
            GoalsManager.activeTasksByGoalId[goalId] = Task {
                await taskToAwait?.value
                var updatedGoal = updatedGoal
                updatedGoal.goalId = goalId
                do{
                    let updatedGoalSM = try GoalSM(from: updatedGoal)
                    if let serverSideId = updatedGoalSM.goalId {
                        try await GoalServices.update(serverSideId, updatedGoalSM)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(goalId)", messageToUser: "Error encountered while updating goal, please try again later or restart the app.")
                        goalsById[goalId] = nil
                    }
                } catch RMLifePlannerError.clientError {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create GoalSM from GoalLM of id \(updatedGoal.goalId)", messageToUser: "Error encountered while updating goal, please try again later.")
                    goalsById[goalId] = oldGoal
                } catch RMLifePlannerError.serverError(let message){
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating goal of id \(goalId)", messageToUser: "Error encountered while updating goal, please try again later.")
                    goalsById[goalId] = oldGoal
                } catch {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating goal", messageToUser: "Error encountered while updating goal, please try again later.")
                    goalsById[goalId] = oldGoal
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a goal of id: \(goalId)", messageToUser: "Error encountered while updating goal, please try again later or restart the app.")
        }
    }
    
    func deleteGoal(goalId: Int) {
        let FUNC_NAME = "GoalsManager.deleteGoal(goalId)"
        if let oldGoal = goalsById[goalId] {
            goalsById[goalId] = nil
            let taskToAwait = GoalsManager.activeTasksByGoalId[goalId]
            Task {
                await taskToAwait?.value
                if let serverSideId = IdsManager.getServerId(from: goalId) {
                    do {
                        try await GoalServices.delete(serverSideId)
                    } catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting goal of id \(goalId)", messageToUser: "Error encountered while deleting goal, please try again later.")
                        goalsById[goalId] = oldGoal
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting goal", messageToUser: "Error encountered while deleting goal, please try again later.")
                        goalsById[goalId] = oldGoal
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(goalId)", messageToUser: "Error encountered while deleting goal, please try again later or restart the app.")
                    goalsById[goalId] = oldGoal
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a goal with id: \(goalId)", messageToUser: "Error encountered while deleting goal, please try again later or restart the app.")
        }
    }
    func deleteGoalsWithDesireId(_ desireId: Int) {
        let goalsToDelete = goalsById.values.filter({ goal in
            goal.desireId == desireId
        })
        for goal in goalsToDelete {
            goalsById.removeValue(forKey: goal.goalId)
            removeFromGoalIdsByDate(goal)
        }
    }
    func invalidateGoalsAfterDate(_ after: Date) {
        let goalsToInvalidate = goalsById.values.filter({ goal in
            goal.startDate >= after
        })
        for goal in goalsToInvalidate {
            goalsById[goal.goalId] = nil
            removeFromGoalIdsByDate(goal)
        }
        Task {
            _ = await getGoalsOnDates([after])
        }
    }
    private func addToGoalIdsByDate(_ goal: GoalLM) {
        for date in goalIdsByDate.keys {
            if date >= goal.startDate {
                if date <= goal.deadlineDate ?? Date.distantFuture {
                    goalIdsByDate[date]?.append(goal.goalId)
                }
            }
        }
    }
    
    private func removeFromGoalIdsByDate(_ goal: GoalLM) {
        for date in goalIdsByDate.keys {
            if date >= goal.startDate {
                if date <= goal.deadlineDate ?? Date.distantFuture {
                    goalIdsByDate[date]?.removeAll(where: { goalId in
                        goalId == goal.goalId
                    })
                }
            }
        }
    }
}
