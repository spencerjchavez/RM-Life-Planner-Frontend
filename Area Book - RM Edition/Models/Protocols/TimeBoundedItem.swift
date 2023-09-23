//
//  CalendarItem.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/1/23.
//

import Foundation

protocol TimeBoundedModel: RMLifePlannerModel {
    var startInstant: Double {get set}
    var endInstant: Double? {get set}
}
