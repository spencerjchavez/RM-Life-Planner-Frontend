//
//  CalendarEventView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/6/23.
//

import SwiftUI

struct CalendarEventView : View, Hashable {
    var event: CalendarEvent
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.blue)
            HStack {
                Text(event.name)
                    .padding()
                Text(Date(timeIntervalSince1970: Double(event.startInstant)).formatted(date: .omitted, time: .shortened) + " - " + Date(timeIntervalSince1970: Double(event.endInstant)).formatted(date: .omitted, time: .shortened))
                    .foregroundColor(.gray)
            }
        }
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
    static func == (lhs: CalendarEventView, rhs: CalendarEventView) -> Bool {
        lhs.event == rhs.event
    }
}
extension CGRect : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minX)
        hasher.combine(minY)
        hasher.combine(width)
        hasher.combine(height)
    }
}
