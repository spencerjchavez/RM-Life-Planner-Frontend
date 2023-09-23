//
//  SQLDateFormatter.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/3/23.
//

import Foundation

struct SQLDateFormatter {
    private static var dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .autoupdatingCurrent
        return df
    }()
    private static var timeFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        df.timeZone = .autoupdatingCurrent
        return df
    }()
    private static var dateTimeFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "yyyy-MM-ddHH:mm:ss"
        df.timeZone = .autoupdatingCurrent
        return df
    }()
    
    static func toSQLDateTimeStrings(_ d: Date) -> (String, String) {
        return (dateFormatter.string(from: d), timeFormatter.string(from: d))
    }
    static func toSQLDateString(_ d: Date) -> String {
        return dateFormatter.string(from: d)
    }
    static func toDate(ymdDate: String, hmsTime: String) -> Date? {
        return dateTimeFormatter.date(from: ymdDate + hmsTime)
    }
    static func toDate(ymdDate: String) -> Date? {
        return dateFormatter.date(from: ymdDate)
    }
}
