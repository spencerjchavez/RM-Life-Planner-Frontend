//
//  UserSM.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/3/23.
//

import Foundation

struct UserSM : Codable {
    var username: String
    var password: String
    var userId: Int
    var email: String
    var googleCalendarId: String?
    var dateJoined: String
    
    init(from lm: UserLM) {
        self.username = lm.username
        self.password = lm.password
        self.userId = lm.userId
        self.email = lm.email
        self.googleCalendarId = lm.googleCalendarId
        self.dateJoined = SQLDateFormatter.toSQLDateString(lm.dateJoined)
    }
}
