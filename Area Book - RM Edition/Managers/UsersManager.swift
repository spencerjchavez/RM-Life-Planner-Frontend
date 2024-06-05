//
//  UsersManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/12/24.
//

import Foundation

class UsersManager {
    
    var authentication: Authentication? = nil
    
    func login(_ login: LoginRequest) async -> (authentication: Authentication, userPreferences: UserPreferencesLM)? {
        let FUNC_NAME = "UsersManager.login(username, password)"
        do {
            let res = try await UserServices.login(login)
            return (authentication: res.authentication, userPreferences: UserPreferencesLM(from: res.userPreferences))
        } catch RMLifePlannerError.serverError(let message) {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Server Error received: \(message)", messageToUser: "Error received, please try again later.")
            }
        } catch let error {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Unknown error received: \(error)", messageToUser: "Error received, please try again later.")
            }
        }
        return nil
    }
    
    func register(_ registerRequest: RegisterRequest) async -> (authentication: Authentication, userPreferences: UserPreferencesLM)? {
        let FUNC_NAME = "UsersManager.register(username, password)"
        do {
            let res = try await UserServices.create(registerRequest)
            return (authentication: res.authentication, userPreferences: UserPreferencesLM(from: res.userPreferences))
        } catch RMLifePlannerError.serverError(let message) {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Server Error received: \(message)", messageToUser: "Error received, please try again later.")
            }
        } catch let error {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: FUNC_NAME, loggingMessage: "Unknown error received: \(error)", messageToUser: "Error received, please try again later.")
            }
        }
        return nil
    }
    
    func logout() async {
        guard let authentication = authentication else {
            DispatchQueue.main.sync {
                ErrorManager.reportError(throwingFunction: "UsersManager.logout()", loggingMessage: "null authentication error", messageToUser: "Error: Please log back in and try again.")
            }
            return
        }
        try? await UserServices.logout(authentication: authentication)
    }
}
