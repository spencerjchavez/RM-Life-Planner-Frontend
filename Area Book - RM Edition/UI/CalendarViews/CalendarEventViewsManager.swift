//
//  CalendarEventViewsManager.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/5/23.
//aaoeu

import Foundation
import SwiftUI

/* class CalendarEventViewsManager : ObservableObject {
    
    var eventRects: [[[CalendarEventWithBounds]]] = [] // [row][column][index in column
    let eventsManager: CalendarEventsManager
    let day: Double
    let eventsXOffset: Double
    var eventsYOffset: Double
    var eventsRenderWidth: Double
    var eventsRenderHeight: Double
    var eventHeightPerSecond: Double
    
    init(day: Double, eventsManager: CalendarEventsManager, eventsRenderWidth: Double, eventsRenderHeight: Double, eventsXOffset: Double, eventsYOffset: Double, eventHeightPerSecond: Double) {
        self.day = day
        self.eventsManager = eventsManager
        self.eventsRenderWidth = eventsRenderWidth
        self.eventsRenderHeight = eventsRenderHeight
        self.eventsXOffset = eventsXOffset
        self.eventsYOffset = eventsYOffset
        self.eventHeightPerSecond = eventHeightPerSecond
    }
    
    func getCalendarViews() -> some View {
        ForEach(eventRects, id: \.self) { row in
            ForEach(row, id: \.self) { col in
                ForEach(col, id: \.self) { eventWithBounds in
                    CalendarEventView(event: eventWithBounds.event)
                        .frame(width: eventWithBounds.bounds!.width,
                               height: eventWithBounds.bounds!.height,
                               alignment: .center)
                        .position(x: eventWithBounds.bounds!.midX,
                                  y: eventWithBounds.bounds!.midY)
                        .onDrag{
                            self.eventsManager.eventIdToDrop = eventWithBounds.event.eventId
                            return NSItemProvider(contentsOf: URL(string: eventWithBounds.event.eventId.description))!
                        } preview: {
                            CalendarEventView(event: eventWithBounds.event)
                                .frame(width: eventWithBounds.bounds!.width,
                                       height: eventWithBounds.bounds!.height)
                        }
                }
            }
        }
    }
    func calculateEventRects() {
        // calculate rectangles
        eventRects = []
        var currRow = -1 // will be changed to 0 as it enters the for loop
        var maxEndInstantInRow = (0,0.0) //index , value
        var minEndInstantInRow = (0,0.0) //index , value
        let events = eventsManager.getEventsOnDay(day: Int(day))
        for event in events {
            //event is guaranteed that:
            //it will start before all the events after it
            //it will end after all the following events if they share a start time
            //it has the lowest eventId if they share start times and end times
            if event.startInstant < maxEndInstantInRow.1 {
                //event adds a new event into the current row, update other events in row too
                if event.startInstant > minEndInstantInRow.1 {
                    //put event under an event that ends before it
                    eventRects[currRow][minEndInstantInRow.0].append(CalendarEventWithBounds(event, nil))
                } else {
                    //add event to end of row in a new column
                    eventRects[currRow].append([CalendarEventWithBounds(event, nil),])
                }
            } else {
                //new row created
                currRow += 1
                eventRects.append([[CalendarEventWithBounds(event, nil),]])
            }
            //update max and min end instants
            maxEndInstantInRow = (0, 0.0)
            minEndInstantInRow = (0, Double.infinity)
            var col_i = 0
            for col in eventRects[currRow] {
                if col.last!.event.endInstant > maxEndInstantInRow.1 {
                    maxEndInstantInRow = (col_i, col.last!.event.endInstant)
                }
                if col.last!.event.endInstant < minEndInstantInRow.1 {
                    minEndInstantInRow = (col_i, col.last!.event.endInstant)
                }
                col_i += 1
            }
        }
        // calculate bounds of each eventRect
        for row in eventRects.indices {
            let width = eventsRenderWidth / Double(eventRects[row].count)
            for col in eventRects[row].indices {
                for i in eventRects[row][col].indices {
                    let event = eventRects[row][col][i].event
                    let startTimeDateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: event.startInstant))
                    eventRects[row][col][i].bounds = CGRect(
                        x: CGFloat(col) * width + eventsXOffset,
                        y: (event.startInstant - event.startDay) *  eventHeightPerSecond + eventsYOffset,
                        width: width,
                        height: (event.endInstant - event.startInstant) * eventHeightPerSecond)
                }
            }
        }
        self.objectWillChange.send() // update new CalendarEventViews
    }
}
*/
