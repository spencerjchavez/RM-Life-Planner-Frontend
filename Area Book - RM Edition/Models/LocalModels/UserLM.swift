//
//  User.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct UserLM {
    
    var username: String
    var password: String
    var userId: Int
    var email: String
    var googleCalendarId: String
    var dateJoined: Date
    
    static func == (lhs: UserLM, rhs: UserLM) -> Bool {
        return lhs.username == rhs.username
    }
    
    init(from sm: UserSM) throws {
        self.username = sm.username
        self.password = sm.password
        self.userId = sm.userId
        self.email = sm.email
        self.googleCalendarId = sm.googleCalendarId
        if let d = SQLDateFormatter.toDate(ymdDate: sm.dateJoined) {
            self.dateJoined = d
        } else {
            throw RMLifePlannerError.clientError
        }
    }
}
