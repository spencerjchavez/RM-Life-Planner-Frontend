//
//  Desire.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct Desire {
    var desireId: Int?
    var name: String
    var userId: Int
    var dateCreated: Double
    var deadline: Float?
    var dateRetired: Float?
    var priorityLevel: Int?
    var colorR: Int
    var colorG: Int
    var colorB: Int
    
    init(desireId: Int? = nil, name: String, userId: Int, dateCreated: Double, deadline: Float? = nil, dateRetired: Float? = nil, priorityLevel: Int? = nil, colorR: Int, colorG: Int, colorB: Int) {
        self.desireId = desireId
        self.name = name
        self.userId = userId
        self.dateCreated = dateCreated
        self.deadline = deadline
        self.dateRetired = dateRetired
        self.priorityLevel = priorityLevel
        self.colorR = colorR
        self.colorG = colorG
        self.colorB = colorB
    }
    init(desireId: Int? = nil, name: String, userId: Int, deadline: Float? = nil, dateRetired: Float? = nil, priorityLevel: Int? = nil, colorR: Int, colorG: Int, colorB: Int) {
        self.desireId = desireId
        self.name = name
        self.userId = userId
        self.dateCreated = Date().timeIntervalSince1970
        self.deadline = deadline
        self.dateRetired = dateRetired
        self.priorityLevel = priorityLevel
        self.colorR = colorR
        self.colorG = colorG
        self.colorB = colorB
    }
}
