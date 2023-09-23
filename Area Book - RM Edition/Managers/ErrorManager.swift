//
//  ErrorManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/31/23.
//

import Foundation
import os

protocol ErrorManagerObserver {
    func didReceiveError(message: String)
}
class ErrorManager {
    static let STD_MSG_TO_USER = "Error encountered, please try again"
    
    private static let logger = Logger(subsystem: GlobalVars.SUBSYSTEM_STR, category: "ErrorManager")
    private static var observers: [ErrorManagerObserver] = []
    static func reportError(throwingFunction: String, loggingMessage: String, messageToUser: String) {
        logger.error("\(throwingFunction, privacy: .public)   \(loggingMessage, privacy: .public)")
        for observer in observers {
            observer.didReceiveError(message: messageToUser)
        }
    }
    static func registerObserver(_ observer: ErrorManagerObserver) {
        observers.append(observer)
    }
}
enum RMLifePlannerError: Error {
    case serverError(String)
    case clientError
}
