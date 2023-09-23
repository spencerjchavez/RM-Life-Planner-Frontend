//
//  TodosManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class TodosManager : ObservableObject {
    
    @Published private var todosById: [Int: TodoLM] = [:]
    @Published private var todoIdsByDate: [Date: [Int]] = [:]
    static var activeTasksByTodoId: [Int: Task<Void, Never>] = [:]
    static var activeTasksByDate: [Date: Task<Void, Never>] = [:]

    
    func createTodo(todo: TodoLM) -> Int {
        let FUNC_NAME = "TodosManager.createTodo(todo)"
        guard todosById[todo.todoId] == nil else {
            ErrorManager.reportError(throwingFunction: "TodosManager.addTodo(todo)", loggingMessage: "Invalid state! Attempted to create todo with id \(todo.todoId), but todo of that id already exists", messageToUser: "Error encountered while adding todo, please try again later.")
            return todo.todoId
        }
        todosById[todo.todoId] = todo
        addToTodoIdsByDate(todo)
        var toAwait: Task<Void, Never>? // must await creation of linked goal first
        if let linkedGoalId = todo.linkedGoalId {
            toAwait = GoalsManager.activeTasksByGoalId[linkedGoalId]
        }
        let toAwaitConst = toAwait
        TodosManager.activeTasksByTodoId[todo.todoId] = Task {
            do {
                await toAwaitConst?.value
                let todoSM = try TodoSM(from: todo)
                let serverSideId = try await TodoServices.create(todoSM)
                IdsManager.associateServerId(serverSideId: serverSideId, with: todo.todoId, modelType: TodoLM.getModelName())
            } catch RMLifePlannerError.serverError(let message){
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while adding todoId \(todo.todoId)", messageToUser: "Error encountered while adding todo, please try again later.")
                todosById[todo.todoId] = nil
            } catch {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating todo", messageToUser: "Error encountered while adding todo, please try again later.")
                todosById[todo.todoId] = nil
            }
        }
        return todo.todoId
    }
    
    func getTodo(todoId: Int) -> TodoLM? {
        let FUNC_NAME = "TodosManager.getTodo(todoId)"
        if let todo = todosById[todoId] {
            return todo
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Failed to get todo with id: \(todoId)", messageToUser: "Error encountered while getting todo, please try again later.")
            return nil
        }
    }
    
    func getLocalTodosOnDate(_ date: Date) -> [TodoLM] {
        return getLocalTodosOnDates([date])[date] ?? []
    }
    
    func getLocalTodosInRange(_ startDate: Date, _ endDate: Date) -> [TodoLM] {
        let FUNC_NAME = "TodosManager.getLocalTodosInRange(startDate, endDate)"
        do {
            let dates = try DateHelper.getDatesInRange(startDate: startDate, endDate: endDate)
            let todosDict = getLocalTodosOnDates(dates)
            var todosSet = Set<TodoLM>()
            for todoList in todosDict.values {
                for todo in todoList {
                    todosSet.insert(todo)
                }
            }
            return Array(todosSet)
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to retrieve in dates of invalid range \(startDate) to \(endDate)", messageToUser: "Error encountered. Please try again")
        }
        return []
    }
    
    func getLocalTodosOnDates(_ dates: [Date]) -> [Date: [TodoLM]] {
        let FUNC_NAME = "TodosManager.getLocalTodosOnDates(dates)"
        var toReturn: [Date: [TodoLM]] = [:]
        var datesToFetchFromServer: [Date] = []
        for date in dates {
            toReturn[date] = []
            if let todoIds = todoIdsByDate[date] {
                for todoId in todoIds {
                    if let todo = todosById[todoId] {
                        toReturn[date]!.append(todo)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state. todoId exists in todosIdsByDay but not found in todosById", messageToUser: "Error encountered, please restart or try again later")
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
            _ = await getTodosOnDates(datesToFetch)
        }
        return toReturn
    }
    
    func getTodosInRange(_ startDate: Date, _ endDate: Date) async -> [TodoLM] {
        let FUNC_NAME = "TodosManager.getTodosInRange(startDate, endDate)"
        do {
            let todoSMs = try await TodoServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), SQLDateFormatter.toSQLDateString(endDate))
            var toReturn: [TodoLM] = []
            for todoSM in todoSMs {
                let todoLM = try TodoLM(from: todoSM)
                addToTodoIdsByDate(todoLM)
                toReturn.append(todoLM)
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos in range \(startDate) - \(endDate)", messageToUser: "Error encountered while getting todos, please try again later.")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
        }
        return []
    }
    
    func getTodosOnDates(_ dates: [Date]) async -> [Date: [TodoLM]] {
        let FUNC_NAME = "TodosManager.getTodosOnDates(dates)"
        do {
            var toReturn: [Date: [TodoLM]] = [:]
            let dateStrings = dates.map({ date in
                SQLDateFormatter.toSQLDateString(date)
            })
            let todosSMByDate = try await TodoServices.getByDates(dateStrings)
            for dateStr in todosSMByDate.keys {
                if let date = SQLDateFormatter.toDate(ymdDate: dateStr) {
                    todoIdsByDate[date] = []
                    toReturn[date] = []
                    if let todoSms = todosSMByDate[dateStr] {
                        for todoSm in todoSms {
                            let todoLM = try TodoLM(from: todoSm)
                            todosById[todoLM.todoId] = todoLM
                            todoIdsByDate[date]?.append(todoLM.todoId)
                            toReturn[date]?.append(todoLM)
                        }
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Could not parse date from date string returned by server: \(dateStr)", messageToUser: "Error encountered, please try again later")

                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos on dates \(dates)", messageToUser: "Error encountered while getting todos, please try again later.")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
        }
        return [:]
    }
    
    func getTodosByGoalIds(_ goalIds: [Int]) async -> [Int: [TodoLM]] {
        let FUNC_NAME = "TodosManager.getTodosbyGoalIds(goalIds)"
        do {
            let serverGoalIds = goalIds.compactMap({ (goalId) -> Int?  in
                guard let serverId = IdsManager.getServerId(from: goalId) else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "goalId \(goalId) did not have an associated serverId", messageToUser: "Error retrieving todos, please try again later")
                    return nil
                }
                return serverId
            })
            let todosSMByGoal = try await TodoServices.getByGoalIds(serverGoalIds)
            var toReturn: [Int: [TodoLM]] = [:]
            for serverGoalId in todosSMByGoal.keys {
                let localGoalId = try IdsManager.getOrGenerateLocalId(from: serverGoalId, modelType: GoalLM.getModelName())
                toReturn[localGoalId] = []
                if let todoSms = todosSMByGoal[serverGoalId] {
                    for todoSm in todoSms {
                        let todoLM = try TodoLM(from: todoSm)
                        if todoLM != todosById[todoLM.todoId] {
                            if let oldTodo = todosById[todoLM.todoId] {
                                removeFromTodoIdsByDate(oldTodo)
                            }
                            todosById[todoLM.todoId] = todoLM
                            addToTodoIdsByDate(todoLM)
                        }
                        toReturn[localGoalId]?.append(todoLM)
                    }
                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos with goalIds: \(goalIds)", messageToUser: "Error encountered while getting todos, please try again later.")
        } catch let err {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
        }
        return [:]
    }
    
    func updateTodo(todoId: Int, updatedTodo: TodoLM) {
        let FUNC_NAME = "TodosManager.updateTodo(todoId, updatedTodo)"
        let taskToAwait = TodosManager.activeTasksByTodoId[todoId]
        if let oldTodo = todosById[todoId] {
            todosById[todoId] = updatedTodo
            if oldTodo.startDate != updatedTodo.startDate || oldTodo.deadlineDate != updatedTodo.deadlineDate {
                // need to change todoIDsByDate
                removeFromTodoIdsByDate(oldTodo)
                addToTodoIdsByDate(updatedTodo)
            }
            TodosManager.activeTasksByTodoId[todoId] = Task {
                await taskToAwait?.value
                var updatedTodo = updatedTodo
                updatedTodo.todoId = todoId
                do{
                    let updatedTodoSM = try TodoSM(from: updatedTodo)
                    if let serverSideId = updatedTodoSM.todoId {
                        try await TodoServices.update(serverSideId, updatedTodoSM)
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(todoId)", messageToUser: "Error encountered while updating todo, please try again later or restart the app.")
                        todosById[todoId] = nil
                    }
                } catch RMLifePlannerError.clientError {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create TodoSM from TodoLM of id \(updatedTodo.todoId)", messageToUser: "Error encountered while updating todo, please try again later.")
                    todosById[todoId] = oldTodo
                } catch RMLifePlannerError.serverError(let message){
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating todo of id \(todoId)", messageToUser: "Error encountered while updating todo, please try again later.")
                    todosById[todoId] = oldTodo
                } catch {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating todo", messageToUser: "Error encountered while updating todo, please try again later.")
                    todosById[todoId] = oldTodo
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a todo of id: \(todoId)", messageToUser: "Error encountered while updating todo, please try again later or restart the app.")
        }
    }
    
    func deleteTodo(todoId: Int) {
        let FUNC_NAME = "TodosManager.deleteTodo(todoId)"
        if let oldTodo = todosById[todoId] {
            todosById[todoId] = nil
            let taskToAwait = TodosManager.activeTasksByTodoId[todoId]
            TodosManager.activeTasksByTodoId[todoId] = Task {
                await taskToAwait?.value
                if let serverSideId = IdsManager.getServerId(from: todoId) {
                    do {
                        try await TodoServices.delete(serverSideId)
                    } catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting todo of id \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later.")
                        todosById[todoId] = oldTodo
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting todo", messageToUser: "Error encountered while deleting todo, please try again later.")
                        todosById[todoId] = oldTodo
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later or restart the app.")
                    todosById[todoId] = oldTodo
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a todo with id: \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later or restart the app.")
        }
    }
    func invalidateTodosAfterDate(after: Date) {
        let todosToInvalidate = todosById.values.filter({ todo in
            todo.startDate >= after
        })
        for todo in todosToInvalidate {
            todosById[todo.todoId] = nil
            removeFromTodoIdsByDate(todo)
        }
        Task {
            _ = await getTodosOnDates([after])
        }
    }
    private func addToTodoIdsByDate(_ todo: TodoLM) {
        for date in todoIdsByDate.keys {
            if date >= todo.startDate {
                if date <= todo.deadlineDate ?? Date.distantFuture {
                    todoIdsByDate[date]?.append(todo.todoId)
                }
            }
        }
    }
    
    private func removeFromTodoIdsByDate(_ todo: TodoLM) {
        for date in todoIdsByDate.keys {
            if date >= todo.startDate {
                if date <= todo.deadlineDate ?? Date.distantFuture {
                    todoIdsByDate[date]?.removeAll(where: { todoId in
                        todoId == todo.todoId
                    })
                }
            }
        }
    }
}
