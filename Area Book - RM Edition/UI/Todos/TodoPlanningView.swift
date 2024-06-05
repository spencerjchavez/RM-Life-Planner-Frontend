//
//  TodoPlanningPopupView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/10/24.
//

import SwiftUI

struct TodoPlanningView: View {
    @EnvironmentObject var appManager: RMLifePlannerManager
    
    var todo: TodoLM
    var hide: () -> Void
    var event: CalendarEventLM?
    @State var name: String = ""
    @State var startInstant: Date = Date.now
    @State var endInstant: Date = Date.now.addingTimeInterval(60 * 30)
    
    
    init(_ todo: TodoLM, hide: @escaping () -> Void, event: CalendarEventLM?) {
        self.todo = todo
        self.hide = hide
        self.event = event
        if let event = event {
            name = event.name
            startInstant = event.startInstant
            endInstant = event.endInstant
        }
    }
    
    var body: some View {
        VStack {
            TextField("Event Name", text: $name)
                .lineLimit(1)
                .padding()
            DatePicker(
                "From: ",
                selection: $startInstant,
                displayedComponents: [.date, .hourAndMinute]
            )
            DatePicker(
                "To: ",
                selection: $endInstant,
                displayedComponents: [.date, .hourAndMinute]
            )
            HStack {
                Button {
                    // cancel
                    hide()
                } label: {
                    Text("Cancel")
                        .padding()
                        .background {
                            Capsule().fill(Colors.backgroundOffWhite)
                        }
                        .padding(.trailing)
                }
                Button {
                    // Save Event
                    guard let authentication = appManager.authentication else {
                        return
                    }
                    let newEvent = CalendarEventLM(userId: authentication.user_id, name: name, startInstant: startInstant, endInstant: endInstant, linkedGoalId: todo.linkedGoalId, linkedTodoId: todo.todoId)
                    if let event = event {
                        appManager.eventsManager.updateCalendarEvent(eventId: event.eventId, updatedCalendarEvent: newEvent)
                    } else {
                        appManager.eventsManager.createCalendarEvent(event: newEvent)
                    }
                    hide()
                } label: {
                    Text("Save Event")
                        .padding()
                        .background {
                            Capsule().fill(Colors.backgroundOffWhite)
                        }
                }
            }
        }
    }
}
