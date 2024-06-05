//
//  File.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 2/25/24.
//

import Foundation
import SwiftUI

struct TodosProgressView: View {
    @EnvironmentObject var appManager: RMLifePlannerManager
    
    let upArrowSystemName = "arrowtriangle.up"
    let downArrowSystemName = "arrowtriangle.down"
    var todos: [TodoLM]
    var eventsByTodoId: [Int: CalendarEventLM]
    @State var minimized: Bool = true
    @State var todoToPlan: TodoLM? = nil
    @State var showTodoPlanning: Bool = false
    
    init(todos: [TodoLM], eventsByTodoId: [Int: CalendarEventLM]) {
        self.todos =  todos
        self.eventsByTodoId = eventsByTodoId
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                HStack {
                    Image(systemName: minimized ? upArrowSystemName : downArrowSystemName)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0).delay(0.5)), removal: .opacity.animation(.easeInOut(duration: 0))))
                    Text("To-Do List")
                    Image(systemName: minimized ? upArrowSystemName : downArrowSystemName)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0).delay(0.5)), removal: .opacity.animation(.easeInOut(duration: 0))))
                }
                Spacer()
            }
            .background {
                Rectangle().fill(Colors.backgroundOffWhite)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            minimized.toggle()
                        }
                    }
            }
            if !minimized {
                VStack (alignment: .leading) {
                    ForEach(todos, id: \.self) { todo in
                        let completionStatus = TodosProgressView.getStatus(todo: todo, linkedEvent: eventsByTodoId[todo.todoId])
                        HStack {
                            Text(todo.name)
                                .padding(.leading)
                            Spacer()
                            // TODO: change styling on these buttons to reflect the current state they're in
                            // planning buttons
                            Text(completionStatus == .unplanned ? " Plan It " : " Planned ")
                                .padding(3)
                                .background {
                                    Capsule().fill(Colors.backgroundOffWhite)
                                }
                                .onTapGesture {
                                    todoToPlan = todo
                                    showTodoPlanning = true
                                }
                            // completion buttons
                            Text(completionStatus == .completed ? " Completed " : " Mark Complete ")
                                .padding(3)
                                .background {
                                    Capsule().fill(Colors.accentColorLight)
                                }
                                .onTapGesture {
                                    if let event = eventsByTodoId[todo.todoId] {
                                        if completionStatus == .completed {
                                            // undo completion
                                            appManager.eventsManager.deleteCalendarEvent(eventId: event.eventId)
                                        } else {
                                            // complete partially-completed event
                                            var updatedEvent = event
                                            updatedEvent.howMuchAccomplished = todo.howMuchPlanned
                                            appManager.eventsManager.updateCalendarEvent(eventId: event.eventId, updatedCalendarEvent: updatedEvent)
                                        }
                                    } else {
                                        guard let authentication = appManager.authentication else {
                                            return
                                        }
                                        appManager.eventsManager.createCalendarEvent(event: CalendarEventLM(userId: authentication.user_id, name: "Completed: \(todo.name)", isHidden: true, startInstant: Date.now, duration: 60, linkedGoalId: todo.linkedGoalId, linkedTodoId: todo.todoId, howMuchAccomplished: todo.howMuchPlanned))
                                    }
                                }
                        }
                        Divider()
                            .frame(height: 1)
                            .foregroundStyle(Colors.backgroundGray.opacity(0.5))
                    }
                }.transition(.move(edge: .bottom))
            }
        }.sheet(isPresented: $showTodoPlanning) {
            if let todoToPlan = todoToPlan {
                TodoPlanningView(todoToPlan, hide: { self.showTodoPlanning = false }, event: self.eventsByTodoId[todoToPlan.todoId])
                    .presentationDetents(
                        [.medium]
                    )
            }
        }
    }
    
    static func getStatus(todo: TodoLM, linkedEvent: CalendarEventLM?) -> Status {
        
        guard let linkedEvent = linkedEvent else {
            return .unplanned
        }
        guard let howMuch = linkedEvent.howMuchAccomplished else {
            return .uncompleted
        }
        if howMuch >= todo.howMuchPlanned {
            return .completed
        }
        if howMuch == 0 {
            return .uncompleted
        }
        return .partial
    }
    enum Status {
        case completed
        case partial
        case uncompleted
        case unplanned
    }
    struct StatusBox : View {
        
        @State var color: Color
        @State var style: StatusBoxStyle
        
        init(_ style: StatusBoxStyle, color: Color) {
            self.color = color
            self.style = style
        }
        
        var body: some View {
            ZStack {
                Rectangle()
                    .stroke(Color.black)
                    .foregroundStyle(style == .half ? Color.clear : self.color)
                if style == .half {
                    CustomTriangle()
                        .fill(color)
                }
            }
        }
        
        struct CustomTriangle: Shape {
            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                return path
            }
        }
        
        enum StatusBoxStyle {
            case full
            case half
        }
    }
}
