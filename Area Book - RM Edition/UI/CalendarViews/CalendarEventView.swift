//
//  CalendarEventView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/6/23.
//

import SwiftUI

struct CalendarEventView : View {
    var event: CalendarEventLM
    
    var body: some View{
        ZStack{
            GeometryReader { reader in
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Colors.coolMint)
                    }
                HStack {
                    Spacer()
                    VStack {
                        if let goalId = event.linkedGoalId {
                            // checkbox to mark completed goals
                            LinkedCheckbox(goalOrTodoid: goalId, type: .goal, event: event)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: 0.1 * reader.size.width)
                                .padding()
                        } else if let todoId = event.linkedTodoId {
                            // checkbox to mark completed todos
                            LinkedCheckbox(goalOrTodoid: todoId, type: .todo, event: event)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: 0.1 * reader.size.width)
                                .padding()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    struct LinkedCheckbox: View {
        
        @EnvironmentObject var appManager: RMLifePlannerManager
        @State var eventCompleted: Bool = false
        let id: Int
        let type: CheckboxType
        @State var event: CalendarEventLM
        
        init(goalOrTodoid: Int, type: CheckboxType, event: CalendarEventLM) {
            self.id = goalOrTodoid
            self.type = type
            self._event = State(initialValue: event)
        }
        
        var body: some View {
            ZStack {
                GeometryReader { reader in
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Colors.backgroundWhite)
                        .padding()
                    // check mark or something else to mark completion
                    if !eventCompleted {
                        Image(systemName: "checkmark")
                            .resizable()
                            .position(CGPoint(x: reader.size.width/1.6, y: reader.size.height/4))
                    }
                }
            }.onTapGesture {
                var planned = 0.0
                if self.type == .goal {
                    planned = appManager.goalsManager.getGoal(goalId: self.id)?.howMuch ?? 0
                } else {
                    planned = appManager.todosManager.getLocalTodo(todoId: self.id)?.howMuchPlanned ?? 0
                }
                if eventCompleted {
                    // undo completion
                    event.howMuchAccomplished = 0
                    appManager.eventsManager.updateCalendarEvent(eventId: event.eventId, updatedCalendarEvent: event)
                    eventCompleted = false
                } else {
                    // mark completed
                    event.howMuchAccomplished = planned
                    appManager.eventsManager.updateCalendarEvent(eventId: event.eventId, updatedCalendarEvent: event)
                    eventCompleted = true
                }
            }
        }
        
        enum CheckboxType {
            case todo
            case goal
        }
    }
}
struct CalendarEventViewPreview: PreviewProvider {
    static var previews: some View {
        CalendarEventView(event: CalendarEventLM(userId: 1, name: "my event", startInstant: Date.now, duration: 5000, linkedGoalId: 2))
    }
}
