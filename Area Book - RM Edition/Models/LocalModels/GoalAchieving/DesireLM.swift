//
//  Desire.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct DesireLM : RMLifePlannerLocalModel {
    
    var desireId: Int
    var name: String
    var userId: Int
    var dateCreated: Date
    var deadline: Date?
    var dateRetired: Date?
    
    init(desireId: Int? = nil, name: String, userId: Int, dateCreated: Date, deadline: Date? = nil, dateRetired: Date? = nil) {
        if let desireId = desireId {
            self.desireId = desireId
        } else {
            self.desireId = try! IdsManager.generateId()
        }
        self.name = name
        self.userId = userId
        self.dateCreated = dateCreated
        self.deadline = deadline
        self.dateRetired = dateRetired
    }
    init(desireId: Int? = nil, name: String, userId: Int, deadline: Date? = nil, dateRetired: Date? = nil) {
        if let desireId = desireId {
            self.desireId = desireId
        } else {
            self.desireId = try! IdsManager.generateId()
        }
        self.name = name
        self.userId = userId
        self.dateCreated = Date.now
        self.deadline = deadline
        self.dateRetired = dateRetired
    }
    init(from sm: DesireSM) throws {
        guard let smDesireId = sm.desireId else {
            throw RMLifePlannerError.serverError("desire returned from server is missing desire id")
        }
        self.desireId = try IdsManager.getOrGenerateLocalId(from: smDesireId, modelType: DesireLM.getModelName())
        self.name = sm.name
        self.userId = sm.userId
        self.dateCreated = SQLDateFormatter.toDate(ymdDate: sm.dateCreated) ?? Date.now
        if let smDateRetired = sm.dateRetired {
            if let d = SQLDateFormatter.toDate(ymdDate: smDateRetired) {
                self.dateRetired = d
            } else {
                throw RMLifePlannerError.clientError
            }
        }
        if let smDeadline = sm.deadline {
            if let d = SQLDateFormatter.toDate(ymdDate: smDeadline) {
                self.deadline = d
            } else {
                throw RMLifePlannerError.clientError
            }
        }
    }
    static func == (lhs: DesireLM, rhs: DesireLM) -> Bool {
        return lhs.desireId == rhs.desireId
    }
    static func getModelName() -> String {
        return "Desire"
    }
}
