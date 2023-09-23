//
//  RecurrencesManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/8/23.
//

import Foundation
import SwiftUI

class RecurrencesManager : ObservableObject {
    
    @Published var recurrencesById: [Int: RecurrenceLM] = [:]
    var activeTasksByRecurrenceId: [Int: Task<Void, Never>] = [:]
    
    func create(_ recurrenceLM: RecurrenceLM) {
        let FUNC_NAME = "RecurrencesManager.create(recurrenceLM)"
        recurrencesById[recurrenceLM.recurrenceId] = recurrenceLM
        do {
            let recurrenceSM = try RecurrenceSM(from: recurrenceLM)
            activeTasksByRecurrenceId[recurrenceLM.recurrenceId] = Task {
                do {
                    let serverSideId = try await RecurrenceServices.create(recurrenceSM)
                    IdsManager.associateServerId(serverSideId: serverSideId, with: recurrenceLM.recurrenceId, modelType: RecurrenceLM.getModelName())
                } catch RMLifePlannerError.serverError(let msg) {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "from server: \(msg)", messageToUser: "error creating object, please try again later")
                } catch let err {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "\(err)", messageToUser: "error creating object, please try again later")
                }
            }
        } catch let error {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not convert recurrenceLM to recurrenceSM! \(error)", messageToUser: "Error in creating item, please try again later")
        }
    }
    
    func update(_ updatedRecurrenceLM: RecurrenceLM, after: Date? = nil) {
        let FUNC_NAME = "RecurrencesManager.update(updatedRecurrenceLM)"
        recurrencesById[updatedRecurrenceLM.recurrenceId] = updatedRecurrenceLM
        do {
            let updatedRecurrenceSM = try RecurrenceSM(from: updatedRecurrenceLM)
            guard let recurrenceIdSM = updatedRecurrenceSM.recurrenceId else {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Invalid state. attempted to update recurrence, but could not get server side recurrence id associated with client side id", messageToUser: "Error encountered, please try again later")
                return
            }
            let toAwait = activeTasksByRecurrenceId[updatedRecurrenceLM.recurrenceId]
            activeTasksByRecurrenceId[updatedRecurrenceLM.recurrenceId] = Task {
                do {
                    await toAwait?.value
                    if let after = after {
                        try await RecurrenceServices.update(recurrenceIdSM, updatedRecurrenceSM, after: SQLDateFormatter.toSQLDateString(after))
                    } else {
                        try await RecurrenceServices.update(recurrenceIdSM, updatedRecurrenceSM)
                    }
                } catch RMLifePlannerError.serverError(let msg) {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "from server: \(msg)", messageToUser: "error creating object, please try again later")
                } catch let err {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "\(err)", messageToUser: "error creating object, please try again later")
                }
            }
        } catch let error {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "could not convert recurrenceLM to recurrenceSM! \(error)", messageToUser: "Error in creating item, please try again later")
        }
    }
    func setEndOfRecurrence(_ recurrenceId: Int, _ date: Date) {
        let FUNC_NAME = "RecurrencesManager.setEndOfRecurrence(recurrenceId, date)"
        guard let recurrence = recurrencesById[recurrenceId] else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Tried to update recurrence id: \(recurrenceId) which does not exist", messageToUser: "error encountered, please try again later")
            return
        }
        recurrence.rrule.recurrenceEnd = EKRecurrenceEnd(end: date)
        recurrencesById[recurrenceId] = recurrence
        if let serverSideId = IdsManager.getServerId(from: recurrenceId) {
            let toAwait = activeTasksByRecurrenceId[recurrenceId]
            activeTasksByRecurrenceId[recurrenceId] = Task {
                do {
                    await toAwait?.value
                    try await RecurrenceServices.setRecurrenceEnd(serverSideId, date: SQLDateFormatter.toSQLDateString(date))
                } catch RMLifePlannerError.serverError(let msg) {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "from server: \(msg)", messageToUser: "error updating object, please try again later")
                } catch let err {
                    ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "\(err)", messageToUser: "error updating object, please try again later")
                }
            }
        } else {
            ErrorManager.reportError(throwingFunction: "RecurrencesManager.setEndOfRecurrence(recurrenceId, date)", loggingMessage: "Could not find associated server recurrence id for id: \(recurrenceId)", messageToUser: "Error encountered, please restart or try again")
        }
    }
    func deleteRecurrence(_ recurrenceId: Int) {
        let FUNC_NAME = "RecurrencesManager.deletRecurrence(recurrenceId)"
        guard let serverSideId = IdsManager.getServerId(from: recurrenceId) else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Could not find associated server recurrence id for id: \(recurrenceId)", messageToUser: "Error encountered, please restart or try again")
            return
        }
        guard let _ = recurrencesById[recurrenceId] else {
            ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Could not delete nonexistant recurrence of id: \(recurrenceId)", messageToUser: "Error encountered, please restart or try again")
            return
        }
        recurrencesById[recurrenceId] = nil
        let toAwait = activeTasksByRecurrenceId[recurrenceId]
        activeTasksByRecurrenceId[recurrenceId] = Task {
            do {
                await toAwait?.value
                try await RecurrenceServices.delete(serverSideId)
            }
            catch RMLifePlannerError.serverError(let msg) {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "from server: \(msg)", messageToUser: "error deleting objects, please try again later")
            } catch let err {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "\(err)", messageToUser: "error deleting objects, please try again later")
            }
        }
    }
}
