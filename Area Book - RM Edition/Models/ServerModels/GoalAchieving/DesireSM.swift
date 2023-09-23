//
//  Desire.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct DesireSM : Codable {
    
    var desireId: Int?
    var name: String
    var userId: Int
    var dateCreated: String
    var deadline: String?
    var dateRetired: String?
    
    init(from lm: DesireLM) {
        self.desireId =  IdsManager.getServerId(from: lm.desireId)
        self.name = lm.name
        self.userId = lm.userId
        self.dateCreated = SQLDateFormatter.toSQLDateString(lm.dateCreated)
        if let lmDateRetired = lm.dateRetired {
            self.dateRetired = SQLDateFormatter.toSQLDateString(lmDateRetired)
        }
        if let lmDeadline = lm.deadline {
            self.deadline = SQLDateFormatter.toSQLDateString(lmDeadline)
        }
    }

    static func == (lhs: DesireSM, rhs: DesireSM) -> Bool {
        return lhs.desireId == rhs.desireId
        
    }
}
