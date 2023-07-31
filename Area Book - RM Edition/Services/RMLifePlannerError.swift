//
//  RMLifePlannerError.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

enum RMLifePlannerError: Error {
    case incorrectUsernameOrPassword
    case notAuthorized
    case resourceNotFound
    case apiTimedOut
    case unexpectedServerSideError
    case unexpectedClientSideError
}
