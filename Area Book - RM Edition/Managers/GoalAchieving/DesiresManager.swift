//
//  DesiresManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/8/23.
//

import Foundation

class DesiresManager : ObservableObject {
    
    @Published var desiresById: [Int: DesireLM] = [:]
    private let managerTaskScheduler = ManagerTaskScheduler()
    var authentication: Authentication? = nil
    
    func createDesire(desire: DesireLM) -> Int {
        let FUNC_NAME = "DesiresManager.createDesire(desire)"
        guard desiresById[desire.desireId] == nil else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state! Attempted to create desire with id \(desire.desireId), but desire of that id already exists", messageToUser: "Error encountered while adding desire, please try again later.")
            return desire.desireId
        }
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return desire.desireId
        }
        desiresById[desire.desireId] = desire
        managerTaskScheduler.schedule(syncId: desire.desireId) {
            do {
                let desireSM = DesireSM(from: desire)
                let serverSideId = try await DesireServices.create(desireSM, authentication: authentication)
                IdsManager.associateServerId(serverSideId: serverSideId, with: desire.desireId, modelType: DesireLM.getModelName())
            } catch RMLifePlannerError.serverError(let message){
                ErrorManager.reportError(throwingFunction: "DesiresManager.addDesire(desire)", loggingMessage: "received error from server: \(message) while adding desireId \(desire.desireId)", messageToUser: "Error encountered while adding desire, please try again later.")
                self.desiresById[desire.desireId] = nil
            } catch {
                ErrorManager.reportError(throwingFunction: "DesiresManager.addDesire(desire)", loggingMessage: "received unknown error while creating desire", messageToUser: "Error encountered while adding desire, please try again later.")
                self.desiresById[desire.desireId] = nil
            }
        }
        return desire.desireId
    }
    
    func getDesire(desireId: Int) -> DesireLM? {
        let FUNC_NAME = "DesiresManager.getDesire(desireId)"
        if let desire = desiresById[desireId] {
            return desire
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Failed to get desire with id: \(desireId)", messageToUser: "Error encountered while getting desire, please try again later.")
        }
        return nil
    }
    
    func getLocalDesiresOfUser() -> [DesireLM] {
        // fetch from server
        if desiresById.isEmpty {
            Task {
                _ = await self.getDesiresOfUser()
            }
            return []
        }
        return Array(desiresById.values)
    }
    
    func getDesiresOfUser() async -> [DesireLM] {
        let FUNC_NAME = "DesiresManager.getDesiresOfUser()"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return []
        }
        do {
            let desires = try await DesireServices.getAll(authentication: authentication)
            var toReturn: [DesireLM] = []
            for desireSM in desires {
                let desireLM = try DesireLM(from: desireSM)
                desiresById[desireLM.desireId] = desireLM
                toReturn.append(desireLM)
            }
            return toReturn
        } catch RMLifePlannerError.serverError(let message){
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while getting desires of user", messageToUser: "Error encountered while getting desires, please try again later.")
        } catch {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while getting desires of user of user", messageToUser: "Error encountered while getting desires, please try again later.")
        }
        // we had an error, return empty list
        return []
    }
    
    func updateDesire(desireId: Int, updatedDesire: DesireLM) {
        let FUNC_NAME = "DesiresManager.updateDesire(desireId, updatedDesire)"
        guard desireId == updatedDesire.desireId else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state, updated desire has different id than original desire", messageToUser: "Error encountered. Please try again later.")
            return
        }
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldDesire = desiresById[desireId] {
            desiresById[desireId] = updatedDesire
            managerTaskScheduler.schedule(syncId: desireId) {
                var updatedDesire = updatedDesire
                updatedDesire.desireId = desireId
                let updatedDesireSM = DesireSM(from: updatedDesire)
                if let serverSideId = updatedDesireSM.desireId {
                    do {
                        try await DesireServices.update(serverSideId, updatedDesireSM, authentication: authentication)
                    }  catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while updating desire of id \(desireId)", messageToUser: "Error encountered while updating desire, please try again later.")
                        self.desiresById[desireId] = oldDesire
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while updating desire", messageToUser: "Error encountered while updating desire, please try again later.")
                        self.desiresById[desireId] = oldDesire
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a server id associated with client id: \(desireId)", messageToUser: "Error encountered while updating desire, please try again later or restart the app.")
                    self.desiresById[desireId] = nil
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a desire of id: \(desireId)", messageToUser: "Error encountered while updating desire, please try again later or restart the app.")
        }
    }
    
    func deleteDesire(desireId: Int) {
        let FUNC_NAME = "DesiresManager.deleteDesire(desireId)"
        guard let authentication = authentication else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "nil authentication found", messageToUser: "Error: Please log in and try again.")
            return
        }
        if let oldDesire = desiresById[desireId] {
            desiresById.removeValue(forKey: desireId)
            managerTaskScheduler.schedule(syncId: desireId) {
                if let serverSideId = IdsManager.getServerId(from: desireId) {
                    do {
                        try await DesireServices.delete(serverSideId, authentication: authentication)
                    } catch RMLifePlannerError.serverError(let message){
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received error from server: \(message) while deleting desire of id \(desireId)", messageToUser: "Error encountered while deleting desire, please try again later.")
                        self.desiresById[desireId] = oldDesire
                    } catch {
                        ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "received unknown error while deleting desire", messageToUser: "Error encountered while deleting desire, please try again later.")
                        self.desiresById[desireId] = oldDesire
                    }
                } else {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "invalid state! failed to find a server id associated with client id: \(desireId)", messageToUser: "Error encountered while deleting desire, please try again later or restart the app.")
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "failed to find a desire with id: \(desireId)", messageToUser: "Error encountered while deleting desire, please try again later or restart the app.")
        }
    }
}
