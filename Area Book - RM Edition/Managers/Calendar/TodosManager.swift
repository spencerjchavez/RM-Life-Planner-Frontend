//
//  TodosManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class TodosManager : ObservableObject {
    
    @Published var todosById: [Int: TodoLM] = [:]
    @Published var todoIdsByDate: [Date: [Int]] = [:]
    private var todoIdsByGoalId: [Int: [Int]] = [:]
    private let managerTaskScheduler = ManagerTaskScheduler()
    var authentication: Authentication? = nil
    
    func createTodo(todo: TodoLM) -> Int {
        let FUNC_NAME = "TodosManager.createTodo(todo)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return todo.todoId
        }
        guard todosById[todo.todoId] == nil else {
            ErrorManager.reportError(throwingFunction: "TodosManager.addTodo(todo)", loggingMessage: "Invalid state! Attempted to create todo with id \(todo.todoId), but todo of that id already exists", messageToUser: "Error encountered while adding todo, please try again later.")
            return todo.todoId
        }
        addToTodoIdsByDate(todo)
        addToTodoIdsByGoalId(todo)
        todosById[todo.todoId] = todo

        managerTaskScheduler.schedule(syncId: todo.todoId) {
            do {
                let todoSM = try DispatchQueue.main.sync { return try TodoSM(from: todo) }
                let serverSideId = try await TodoServices.create(todoSM, authentication: authentication)
                DispatchQueue.main.sync {
                    IdsManager.associateServerId(serverSideId: serverSideId, with: todo.todoId, modelType: TodoLM.getModelName())
                }
            } catch RMLifePlannerError.serverError(let message){
                DispatchQueue.main.sync {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while adding todoId \(todo.todoId)", messageToUser: "Error encountered while adding todo, please try again later.")
                    self.todosById[todo.todoId] = nil
                    self.removeFromTodoIdsByDate(todo)
                    self.removeFromTodoIdsByGoalId(todo)
                }
            } catch {
                DispatchQueue.main.sync {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while creating todo", messageToUser: "Error encountered while adding todo, please try again later.")
                    self.todosById[todo.todoId] = nil
                    self.removeFromTodoIdsByDate(todo)
                    self.removeFromTodoIdsByGoalId(todo)
                }
            }
        }
        return todo.todoId
    }
    
    func getLocalTodo(todoId: Int) -> TodoLM? {
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
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return []
        }
        do {
            let todoSMs = try await TodoServices.getByDateRange(SQLDateFormatter.toSQLDateString(startDate), SQLDateFormatter.toSQLDateString(endDate), authentication: authentication)
            var toReturn: [TodoLM] = []
            try DispatchQueue.main.sync {
                for todoSM in todoSMs {
                    let todoLM = try TodoLM(from: todoSM)
                    todosById[todoLM.todoId] = todoLM
                    addToTodoIdsByDate(todoLM)
                    addToTodoIdsByGoalId(todoLM)
                    toReturn.append(todoLM)
                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos in range \(startDate) - \(endDate)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        } catch let err {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        }
        return []
    }
    
    func getTodosOnDates(_ dates: [Date]) async -> [Date: [TodoLM]] {
        let FUNC_NAME = "TodosManager.getTodosOnDates(dates)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return [:]
        }
        do {
            var toReturn: [Date: [TodoLM]] = [:]
            let dateStrings = dates.map({ date in
                SQLDateFormatter.toSQLDateString(date)
            })
            let todosSMByDate = try await TodoServices.getByDates(dateStrings, authentication: authentication)
            try DispatchQueue.main.sync {
                for dateStr in todosSMByDate.keys {
                    if let date = SQLDateFormatter.toDate(ymdDate: dateStr) {
                        todoIdsByDate[date] = []
                        toReturn[date] = []
                        if let todoSms = todosSMByDate[dateStr] {
                            for todoSm in todoSms {
                                let todoLM = try TodoLM(from: todoSm)
                                todosById[todoLM.todoId] = todoLM
                                todoIdsByDate[date]?.append(todoLM.todoId)
                                addToTodoIdsByGoalId(todoLM)
                                toReturn[date]?.append(todoLM)
                            }
                        }
                    } else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Could not parse date from date string returned by server: \(dateStr)", messageToUser: "Error encountered, please try again later")
                        
                    }
                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message) {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos on dates \(dates)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        } catch let err {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        }
        return [:]
    }
    
    func getTodosByGoalIds(_ goalIds: [Int]) async -> [Int: [TodoLM]] {
        let FUNC_NAME = "TodosManager.getTodosbyGoalIds(goalIds)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return [:]
        }
        do {
            // init todo ids by goal ids to prevent this being called multiple times
            let serverGoalIds = DispatchQueue.main.sync {
                for goalId in goalIds {
                    self.todoIdsByGoalId[goalId] = []
                }
                let serverGoalIds = goalIds.compactMap({ (goalId) -> Int?  in
                    guard let serverId = IdsManager.getServerId(from: goalId) else {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "goalId \(goalId) did not have an associated serverId", messageToUser: "Error retrieving todos, please try again later")
                        return nil
                    }
                    return serverId
                })
                return serverGoalIds
            }
            let todosSMByGoal = try await TodoServices.getByGoalIds(serverGoalIds, authentication: authentication)
            var toReturn: [Int: [TodoLM]] = [:]
            try DispatchQueue.main.sync {
                for serverGoalId in todosSMByGoal.keys {
                    let localGoalId = try IdsManager.getOrGenerateLocalId(from: serverGoalId, modelType: GoalLM.getModelName())
                    toReturn[localGoalId] = []
                    if let todoSms = todosSMByGoal[serverGoalId] {
                        for todoSm in todoSms {
                            let todoLM = try TodoLM(from: todoSm)
                            if todoLM != todosById[todoLM.todoId] {
                                if let oldTodo = todosById[todoLM.todoId] {
                                    removeFromTodoIdsByDate(oldTodo)
                                    removeFromTodoIdsByGoalId(oldTodo)
                                }
                                addToTodoIdsByDate(todoLM)
                                addToTodoIdsByGoalId(todoLM)
                                todosById[todoLM.todoId] = todoLM
                            }
                            toReturn[localGoalId]?.append(todoLM)
                        }
                    }
                }
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting todos with goalIds: \(goalIds)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        } catch let err {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error while getting todos: \(err)", messageToUser: "Error encountered while getting todos, please try again later.")
            }
        }
        return [:]
    }
    
    func getLocalTodosByGoalIds(_ goalIds: [Int]) -> [Int: [TodoLM]] {
        // return events
        var toReturn: [Int: [TodoLM]] = [:]
        var toFetch: [Int] = []
        for goalId in goalIds {
            if let todoIds = self.todoIdsByGoalId[goalId] {
                let todos = todoIds.compactMap({ todoId in
                    return self.todosById[todoId]
                })
                toReturn[goalId] = todos
            } else {
                toFetch.append(goalId)
                self.todoIdsByGoalId[goalId] = []
            }
        }
        let toFetchFromServer = toFetch
        Task {
            _ = await self.getTodosByGoalIds(toFetchFromServer)
        }
        return toReturn
    }
    
    func updateTodo(todoId: Int, updatedTodo: TodoLM) {
        let FUNC_NAME = "TodosManager.updateTodo(todoId, updatedTodo)"
        guard todoId == updatedTodo.todoId else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, updated todo has different id than original todo", messageToUser: "Error encountered. Please try again later.")
            return
        }
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldTodo = todosById[todoId] {
            todosById[todoId] = updatedTodo
            removeFromTodoIdsByDate(oldTodo)
            removeFromTodoIdsByGoalId(oldTodo)
            addToTodoIdsByDate(updatedTodo)
            addToTodoIdsByGoalId(updatedTodo)
            managerTaskScheduler.schedule(syncId: updatedTodo.todoId) {
                var updatedTodo = updatedTodo
                updatedTodo.todoId = todoId
                do {
                    let updatedTodoSM = try DispatchQueue.main.sync{ return try TodoSM(from: updatedTodo) }
                    if let serverSideId = updatedTodoSM.todoId {
                        try await TodoServices.update(serverSideId, updatedTodoSM, authentication: authentication)
                    } else {
                        DispatchQueue.main.async {
                            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(todoId)", messageToUser: "Error encountered while updating todo, please try again later or restart the app.")
                            self.todosById[todoId] = nil
                            self.addToTodoIdsByDate(oldTodo)
                            self.addToTodoIdsByGoalId(oldTodo)
                        }
                    }
                } catch RMLifePlannerError.clientError {
                    DispatchQueue.main.sync {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not create TodoSM from TodoLM of id \(updatedTodo.todoId)", messageToUser: "Error encountered while updating todo, please try again later.")
                        self.todosById[todoId] = oldTodo
                        self.addToTodoIdsByDate(oldTodo)
                        self.addToTodoIdsByGoalId(oldTodo)
                    }
                } catch RMLifePlannerError.serverError(let message){
                    DispatchQueue.main.sync {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating todo of id \(todoId)", messageToUser: "Error encountered while updating todo, please try again later.")
                        self.todosById[todoId] = oldTodo
                        self.addToTodoIdsByDate(oldTodo)
                        self.addToTodoIdsByGoalId(oldTodo)
                    }
                } catch {
                    DispatchQueue.main.sync {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating todo", messageToUser: "Error encountered while updating todo, please try again later.")
                        self.todosById[todoId] = oldTodo
                        self.addToTodoIdsByDate(oldTodo)
                        self.addToTodoIdsByGoalId(oldTodo)
                    }
                }
            }
        } else {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a todo of id: \(todoId)", messageToUser: "Error encountered while updating todo, please try again later or restart the app.")
            }
        }
    }
    
    func deleteTodo(todoId: Int) {
        let FUNC_NAME = "TodosManager.deleteTodo(todoId)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldTodo = todosById[todoId] {
            todosById[todoId] = nil
            removeFromTodoIdsByDate(oldTodo)
            removeFromTodoIdsByGoalId(oldTodo)
            managerTaskScheduler.schedule(syncId: todoId) {
                if let serverSideId = DispatchQueue.main.sync(execute: { return IdsManager.getServerId(from: todoId) }) {
                    do {
                        try await TodoServices.delete(serverSideId, authentication: authentication)
                    } catch RMLifePlannerError.serverError(let message){
                        DispatchQueue.main.sync {
                            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting todo of id \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later.")
                            self.todosById[todoId] = oldTodo
                            self.addToTodoIdsByDate(oldTodo)
                            self.addToTodoIdsByGoalId(oldTodo)
                        }
                    } catch {
                        DispatchQueue.main.sync {
                            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting todo", messageToUser: "Error encountered while deleting todo, please try again later.")
                            self.todosById[todoId] = oldTodo
                            self.addToTodoIdsByDate(oldTodo)
                            self.addToTodoIdsByGoalId(oldTodo)
                        }
                    }
                } else {
                    DispatchQueue.main.sync {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later or restart the app.")
                        self.todosById[todoId] = oldTodo
                        self.addToTodoIdsByDate(oldTodo)
                        self.addToTodoIdsByGoalId(oldTodo)
                    }
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a todo with id: \(todoId)", messageToUser: "Error encountered while deleting todo, please try again later or restart the app.")
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
    private func addToTodoIdsByGoalId(_ todo: TodoLM) {
        if let linkedGoalId = todo.linkedGoalId {
            var todoIds = todoIdsByGoalId[linkedGoalId] ?? []
            todoIds.append(todo.todoId)
            todoIdsByGoalId[linkedGoalId] = todoIds
        }
    }
    private func removeFromTodoIdsByGoalId(_ todo: TodoLM) {
        if let linkedGoalId = todo.linkedGoalId {
            var todoIds = self.todoIdsByGoalId[linkedGoalId] ?? []
            todoIds.removeAll(where: { todoId in
                todoId == todo.todoId
            })
            self.todoIdsByGoalId[linkedGoalId] = todoIds
        }
    }
}
