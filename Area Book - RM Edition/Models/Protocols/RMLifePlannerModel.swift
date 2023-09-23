//
//  ItemWithId.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/2/23.
//

import Foundation

protocol RMLifePlannerLocalModel: Hashable, Codable {
    static func getModelName() -> String
}
