//
//  CalendarEventDropDelegate.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/4/23.
//

import Foundation
import SwiftUI

class CalendarEventDropDelegate : NSObject, DropDelegate {
    @Binding var proposedNewStartInstant: Date?
    @Binding var isProposingDrop: Bool
    let date: Date
    let yOffSet: Double
    let maxY: Double
    let appManager: RMLifePlannerManager
    
    static var eventIdToDrop: Int = 1
    
    init(appManager: RMLifePlannerManager, isProposingDrop: Binding<Bool>, proposedNewStartInstant: Binding<Date?>, date: Date, yOffSet: Double, maxY: Double) {
        self.appManager = appManager
        self._proposedNewStartInstant = proposedNewStartInstant
        self._isProposingDrop = isProposingDrop
        self.date = date
        self.yOffSet = yOffSet
        self.maxY = maxY
    }
    
    func performDrop(info: DropInfo) -> Bool {
        isProposingDrop = false
        if let proposedNewStartInstant = proposedNewStartInstant {
            let eventIdToDrop = CalendarEventDropDelegate.eventIdToDrop
            guard eventIdToDrop != 1 else { return false }
            CalendarEventDropDelegate.eventIdToDrop = -1
            guard var event = appManager.eventsManager.getCalendarEvent(eventId: eventIdToDrop) else {
                ErrorManager.reportError(throwingFunction: "CalendarEventDropDelegate.performDrop(info)", loggingMessage: "Attempted to drop event which doesn't exist in storage. id: \(eventIdToDrop)", messageToUser: "Error moving specified event, please try again later")
                return false
            }
            event.updateStartInstant(proposedNewStartInstant)
            appManager.eventsManager.updateCalendarEvent(eventId: eventIdToDrop, updatedCalendarEvent: event)
            return true
        }
        return false
    }
    
    func dropExited(info: DropInfo) {
        isProposingDrop = false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        isProposingDrop = true
        let y = info.location.y
        //print("y-value = \(y)")
        //y = seconds / 60 / 60 * (eventsRenderHeight / 25) + eventsYOffset)
        var newStartInstant = date.addingTimeInterval((y - yOffSet) / (maxY/25) * 60 * 60)
        //round newStartInstant to nearest 15 minute interval
        var dc = Calendar.current.dateComponents([.minute], from: newStartInstant)
        var newMinute = round(Double(dc.minute ?? 0) / 15.0) * 15
        
        newStartInstant = (Calendar.current.date(bySetting: .minute, value: 0, of: newStartInstant)!.addingTimeInterval(TimeInterval(60 * newMinute)))
        proposedNewStartInstant = newStartInstant
        return nil
    }
    
    func dropEntered(info: DropInfo) {
        isProposingDrop = true
    }
}
