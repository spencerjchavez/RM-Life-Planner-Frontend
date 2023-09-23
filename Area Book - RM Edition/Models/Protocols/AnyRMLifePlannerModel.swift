//
//  AnyRMLifePlannerModel.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/16/23.
//

import Foundation

struct AnyRMLifePlannerModel: RMLifePlannerModel {
    var id: Int
    
    func getId() -> Int {
        return id
    }
    
    mutating func setId(id: Int) {
        self.id = id
    }
    mutating func convertToClientSideObject() {
    }
    mutating func convertToServerSideObject() throws {
    }
}
