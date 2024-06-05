//
//  GoalsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class GoalsManager : ObservableObject {
    
    @Published var goalsById: [Int: GoalLM] = [:]
    @Published var goalIdsByDate: [Date: [Int]] = [:]
    private let managerTaskScheduler = ManagerTaskScheduler()
    var authentication: Authentication? = nil
    
    func createGoal(goal: GoalLM) -> Int {
        let FUNC_NAME = "GoalsManager.createGoal(goal)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return goal.goalId
        }
        guard goalsById[goal.goalId] == nil else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to create goal with id \(goal.goalId), but goal of that id already exists", messageToUser: "Error encountered while adding goal, please try again later.")
            return goal.goalId
        }
        goalsById[goal.goalId] = goal
        addToGoalIdsByDate(goal)
        managerTaskScheduler.schedule(syncId: goal.goalId) {
            do {
                let goalSM = try GoalSM(from: goal)
                let serverSideId = try await GoalServices.create(goalSM, authentication: authentication)
                IdsManager.associateServerId(serverSideId: serverSideId, with: goal.goalId, modelType: GoalLM.getModelName())
            } catch RMLifePlannerError.serverError(let message){
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while adding goalId \(goal.goalId)", messageToUser: "Error encountered while adding goal, please try again later.")
                self.goalsById[goal.goalId] = nil
            } catch {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating goal", messageToUser: "Error encountered while adding goal, please try again later.")
                self.goalsById[goal.goalId] = nil
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
    
    func getLocalGoalsInRange(_ startDate: Date, _ endDate: Date?) -> [GoalLM] {
        // TODO: make this crap more efficient. Should not need to split a date range up into every individual date
        let FUNC_NAME = "GoalsManager.getLocalGoalsInRange(startDate, endDate)"
        do {
            if let endDate = endDate {
                let dates = try DateHelper.getDatesInRange(startDate: startDate, endDate: endDate)
                let goalsDict = getLocalGoalsOnDates(dates)
                var goalsSet = Set<GoalLM>()
                for goalList in goalsDict.values {
                    for goal in goalList {
                        goalsSet.insert(goal)
                    }
                }
                return Array(goalsSet)
            } else {
                // fetch from server
                Task {
                    await getGoalsInRange(startDate, nil)
                }
                
                let goalIds = goalIdsByDate.flatMap({ date, goalIds in
                    return date >= startDate ? goalIds : []
                })
                let goalIdsSet = Set(goalIds)
                let goals = goalIdsSet.compactMap( { goalId in
                    return goalsById[goalId]
                })
                return goals
            }
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to retrieve in dates of invalid range \(startDate) to \(endDate ?? startDate)", messageToUser: "Error encountered. Please try again")
        }
        return []
    }
    
    func getLocalGoalsOnDates(_ dates: [Date]) -> [Date: [GoalLM]] {
        let FUNC_NAME = "GoalsManager(getLocalGoalsOnDates(dates)"
        var toReturn: [Date: [GoalLM]] = [:]
        var toFetchFromServer: [Date] = []
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
                toFetchFromServer.append(date)
            }
        }
        let toFetch = toFetchFromServer
        Task {
            _ = await getGoalsOnDates(toFetch)
        }
        return toReturn
    }
    
    func getGoalsInRange(_ startDate: Date, _ endDate: Date?) async -> [GoalLM] {
        let FUNC_NAME = "GoalsManager.getGoalsInRange(startDate, endDate)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return []
        }
        do {
            let endDateString = endDate == nil ? nil : SQLDateFormatter.toSQLDateString(endDate!)
            let goalSMs = try await GoalServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), endDateString, authentication: authentication)
            var toReturn: [GoalLM] = []
            for goalSM in goalSMs {
                let goalLM = try GoalLM(from: goalSM)
                self.goalsById[goalLM.goalId] = goalLM
                addToGoalIdsByDate(goalLM)
                toReturn.append(goalLM)
            }
            return toReturn
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Error received while attempting to retrieve goals in range \(startDate) to \(endDate ?? startDate)", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        return []
    }
    
    func getGoalsOnDates(_ dates: [Date]) async -> [Date: [GoalLM]] {
        let FUNC_NAME = "GoalsManager.getGoalsOnDates(dates)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return [:]
        }
        do {
            // init goal ids on dates to prevent this being called multiple times
            for date in dates {
                self.goalIdsByDate[date] = []
            }
            let dateStrs = dates.map({ date in
                SQLDateFormatter.toSQLDateString(date)
            })
            var toReturn: [Date: [GoalLM]] = [:]
            let goalsSMByDate = try await GoalServices.getByDates(dateStrs, authentication: authentication)
            try DispatchQueue.main.sync {
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
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message) {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server with message: \(message)", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Unknown error received while attempting to retrieve goals", messageToUser: "Error encountered while fetching goals, please try again later")
        }
        return [:]
    }
    
    func updateGoal(goalId: Int, updatedGoal: GoalLM) {
        let FUNC_NAME = "GoalsManager.updateGoal(goalId, updatedGoal)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        guard goalId == updatedGoal.goalId else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, updated goal has different id than original goal", messageToUser: "Error encountered. Please try again later.")
            return
        }
        if let oldGoal = goalsById[goalId] {
            goalsById[goalId] = updatedGoal
            if oldGoal.startDate != updatedGoal.startDate || oldGoal.deadlineDate != updatedGoal.deadlineDate {
                // need to change goalIDsByDate
                removeFromGoalIdsByDate(oldGoal)
                addToGoalIdsByDate(updatedGoal)
            }
            managerTaskScheduler.schedule(syncId: updatedGoal.goalId) {
                var updatedGoal = updatedGoal
                updatedGoal.goalId = goalId
                do{
                    let updatedGoalSM = try GoalSM(from: updatedGoal)
                    if let serverSideId = updatedGoalSM.goalId {
                        try await GoalServices.update(serverSideId, updatedGoalSM, authentication: authentication)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(goalId)", messageToUser: "Error encountered while updating goal, please try again later or restart the app.")
                        self.goalsById[goalId] = nil
                    }
                } catch RMLifePlannerError.clientError {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create GoalSM from GoalLM of id \(updatedGoal.goalId)", messageToUser: "Error encountered while updating goal, please try again later.")
                    self.goalsById[goalId] = oldGoal
                } catch RMLifePlannerError.serverError(let message){
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating goal of id \(goalId)", messageToUser: "Error encountered while updating goal, please try again later.")
                    self.goalsById[goalId] = oldGoal
                } catch {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating goal", messageToUser: "Error encountered while updating goal, please try again later.")
                    self.goalsById[goalId] = oldGoal
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a goal of id: \(goalId)", messageToUser: "Error encountered while updating goal, please try again later or restart the app.")
        }
    }
    
    func deleteGoal(goalId: Int) {
        let FUNC_NAME = "GoalsManager.deleteGoal(goalId)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldGoal = goalsById[goalId] {
            removeFromGoalIdsByDate(oldGoal)
            goalsById[goalId] = nil
            managerTaskScheduler.schedule(syncId: goalId) {
                if let serverSideId = IdsManager.getServerId(from: goalId) {
                    do {
                        try await GoalServices.delete(serverSideId, authentication: authentication)
                    } catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting goal of id \(goalId)", messageToUser: "Error encountered while deleting goal, please try again later.")
                        self.addToGoalIdsByDate(oldGoal)
                        self.goalsById[goalId] = oldGoal
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting goal", messageToUser: "Error encountered while deleting goal, please try again later.")
                        self.addToGoalIdsByDate(oldGoal)
                        self.goalsById[goalId] = oldGoal
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(goalId)", messageToUser: "Error encountered while deleting goal, please try again later or restart the app.")
                    self.addToGoalIdsByDate(oldGoal)
                    self.goalsById[goalId] = oldGoal
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
            removeFromGoalIdsByDate(goal)
            goalsById.removeValue(forKey: goal.goalId)
        }
    }
    /*func invalidateGoalsAfterDate(_ after: Date) {
        let goalsToInvalidate = goalsById.values.filter({ goal in
            goal.startDate >= after
        })
        for goal in goalsToInvalidate {
            removeFromGoalIdsByDate(goal)
            goalsById[goal.goalId] = nil
        }
        Task {
            _ = await getGoalsOnDates([after])
        }
    } */
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
