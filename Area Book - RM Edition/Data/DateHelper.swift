//
//  DateHelper.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/4/23.
//

import Foundation

struct DateHelper {
    static func getDateAtMidnight(_ date: Date) throws -> Date {
        guard let newDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
            throw RMLifePlannerError.clientError
        }
        return newDate
    }
    static func getDatesInRange(startDate: Date, endDate: Date) throws -> [Date]  {
        let startDate = try getDateAtMidnight(startDate)
        let endDate = try getDateAtMidnight(endDate)
        if endDate < startDate {
            throw NSError()
        }
        if endDate == startDate {
            return [startDate]
        }
        var curr_date = startDate
        var dates: [Date] = []
        while curr_date < endDate {
            dates.append(curr_date)
            //get next_day
            var date_components = DateComponents()
            date_components.day = 1
            guard let newDate = Calendar.current.date(byAdding: date_components, to: curr_date) else {
                throw RMLifePlannerError.clientError
            }
            curr_date = newDate
        }
        return dates
    }
}
