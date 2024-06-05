import SwiftUI

struct CalendarDayView: View {
    @EnvironmentObject var appManager: RMLifePlannerManager
    private let date: Date
    @Binding private var navigationPath: NavigationPath
    let eventsXOffset = 50.0
    @State private var eventsYOffset = 0.0
    @State private var eventsRenderWidth = 0.0
    @State private var eventsRenderHeight = 1500.0
    @State private var eventHeightPerSecond = 0.0
    
    @State private var eventsById: [Int: CalendarEventLM] = [:]
    @State private var eventBounds: [Int: CGRect] = [:] // by eventId
    @State private var eventIdsByDaySubscriber: Any? = nil
    @State private var eventsByIdSubscriber: Any? = nil
    @State private var isProposingDrop: Bool = false
    @State private var proposedNewStartInstant: Date? = nil
    
    @State private var goals: [GoalLM] = []
    @State private var goalIdsByDaySubscriber: Any? = nil
    @State private var todos: [TodoLM] = []
    @State private var TodoIdsByDaySubscriber: Any? = nil
    @State private var eventsByTodoId: [Int: CalendarEventLM] = [:]
    
    var previewEventDropYValue : Double? {
        if let proposedNewStartInstant = proposedNewStartInstant {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: proposedNewStartInstant)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            let seconds = (hour * 60 + minute) * 60 + second
            return Double(seconds) / 60 / 60 * eventsRenderHeight / 25 + eventsYOffset
        }
        return nil
    }
    var proposedNewStartTimeString: String? {
        if let proposedNewStartInstant = proposedNewStartInstant {
            return proposedNewStartInstant.formatted(date: .omitted, time: .shortened)
        }
        return nil
    }
    var eventDropPreviewText: String? {
        if let _ = proposedNewStartInstant {
            if let proposedNewStartTimeString = proposedNewStartTimeString {
                return "move event to" + proposedNewStartTimeString
            }
        }
        return nil
    }
    
    init(date: Date, navigationPath: Binding<NavigationPath>) {
        self.date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
        self._navigationPath = navigationPath
        
    }
    var body: some View {
        VStack {
            GeometryReader { globalGeometry in
                ScrollView{
                    ScrollViewReader { reader in
                        ZStack() {
                            Color.clear
                            Rectangle() //used to capture drop events and register create event taps
                                .fill(.white)
                                .frame(width: globalGeometry.size.width, height: eventsRenderHeight)
                                .onDrop(of: [.url], delegate: CalendarEventDropDelegate(appManager: appManager, isProposingDrop: $isProposingDrop, proposedNewStartInstant: $proposedNewStartInstant, date: date, yOffSet: eventsYOffset, maxY: eventsRenderHeight))
                                .onTapGesture (coordinateSpace: CoordinateSpace.local) { location in
                                    navigationPath.append(CalendarEventModificationView(startInstant: instantFromYCoordinate(location.y), navigationPath: $navigationPath))
                                }
                            ForEach(0..<24, id: \.self) { hour in
                                ZStack {
                                    HStack{
                                        Text(hour == 0 ? "12 am" : (hour < 12 ? hour.description + " am" : (hour == 12 ? "12 pm" : (hour - 12).description + " pm")))
                                        Rectangle()
                                            .fill(.gray)
                                            .frame(height: 2.0)
                                            .id("hour" + String(hour))
                                    }
                                }
                                .position(x: globalGeometry.size.width / 2.0, y: yCoordinateByHour(Double(hour)))
                                .allowsHitTesting(false)
                            }
                            
                            ForEach(Array(eventsById.values), id: \.eventId) { event in
                                let bounds = eventBounds[event.eventId] ?? .zero
                                CalendarEventView(event: event)
                                    .frame(width: bounds.width,
                                           height: bounds.height,
                                           alignment: .center)
                                    .position(x: bounds.midX,
                                              y: bounds.midY)
                                    .onTapGesture {
                                        navigationPath.append(CalendarEventModificationView(event: event, navigationPath: $navigationPath))
                                    }
                                    .onDrag {
                                        CalendarEventDropDelegate.eventIdToDrop = event.eventId
                                        return NSItemProvider()
                                    } preview: {
                                        CalendarEventView(event: event)
                                            .frame(width: bounds.width, height: bounds.height, alignment: .center)
                                    }
                                    .allowsHitTesting(!isProposingDrop)
                            }
                            //drop preview time view
                            if isProposingDrop {
                                HStack{
                                    Text(proposedNewStartTimeString ?? "nil")
                                        .foregroundColor(.green)
                                    Rectangle()
                                        .fill(.black)
                                        .frame(height: 2.0)
                                }
                                .position(x: globalGeometry.size.width / 2, y: previewEventDropYValue ?? 0)
                                .allowsHitTesting(false)
                            }
                        }
                        .frame(height: eventsRenderHeight + eventsYOffset)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                   // get events and calculate their bounds
                                    eventsRenderWidth = geometry.size.width - eventsXOffset
                                    eventHeightPerSecond = eventsRenderHeight / 25.0 / 60.0 / 60.0
                                    eventsYOffset = eventHeightPerSecond * 60 * 60 / 2.0

                                    _ = self.appManager.eventsManager.getLocalCalendarEventsOnDate(self.date)
                                    _ = self.appManager.todosManager.getLocalTodosOnDate(self.date)
                                    _ = self.appManager.goalsManager.getLocalGoalsOnDate(self.date)
                                    self.eventIdsByDaySubscriber = appManager.eventsManager.$eventIdsByDate.sink(receiveValue: { eventIdsByDate in
                                        self.eventsById = [:]
                                        self.eventsByTodoId = [:]
                                        for eventId in eventIdsByDate[self.date] ?? [] {
                                            if let event = appManager.eventsManager.getCalendarEvent(eventId: eventId) {
                                                self.eventsById[event.eventId] = event
                                                if let linkedTodoId = event.linkedTodoId {
                                                    self.eventsByTodoId[linkedTodoId] = event
                                                }
                                            }
                                        }
                                    })
                                    self.eventsByIdSubscriber = appManager.eventsManager.$eventsById.sink(receiveValue: { eventsById in
                                        // TODO: change this so we only calculate events on this date
                                        calculateEventRects(eventsById)
                                    })
                                
                                    // get todos and goals. perhaps move this logic somewhere else in the future
                                    self.goalIdsByDaySubscriber = appManager.goalsManager.$goalIdsByDate.sink(receiveValue: { goalsIdsByDate in
                                        let ids = goalsIdsByDate[self.date] ?? []
                                        self.goals = ids.compactMap({ id in
                                            self.appManager.goalsManager.getGoal(goalId: id)
                                        })
                                    })
                                    self.TodoIdsByDaySubscriber = appManager.todosManager.$todoIdsByDate.sink(receiveValue: { todoIdsByDate in
                                        let ids = todoIdsByDate[self.date] ?? []
                                        self.todos = ids.compactMap({ id in
                                            self.appManager.todosManager.getLocalTodo(todoId: id)
                                        })
                                    })
                                    
                                    reader.scrollTo("hour6", anchor: .top)
                                }
                            }
                        )
                    } // scrollViewReader
                } // scrollView
            } // globalGeometry
            // display all current todos
            TodosProgressView(todos: todos, eventsByTodoId: eventsByTodoId)
        }
    }
    func calculateEventRects(_ eventsById: [Int: CalendarEventLM]) {
        // calculate rectangles
        var events = Array(eventsById.values)
        events = events.sorted(by: { event1, event2 in
            if event1.startInstant < event2.startInstant {
                return true
            } else if event2.startInstant < event1.startInstant {
                return false
            }
            // start instances are equal
            if event1.endInstant > event2.endInstant {
                return true
            } else if event2.endInstant > event1.endInstant {
                return false
            }
            // end instances are equal
            if event1.eventId < event2.eventId {
                return true
            }
            return false
        })
        var eventRects: [[[CalendarEventLM]]] = []
        var currRow = -1 // will be changed to 0 as it enters the for loop
        var maxEndInstantInRow = (0,Date.distantPast) //index , value
        var minEndInstantInRow = (0,Date.distantFuture) //index , value
        for event in events {
            //event is guaranteed that:
            //it will start before all the events after it
            //it will end after all the following events if they share a start time
            //it has the lowest eventId if they share start times and end times
            if event.startInstant < maxEndInstantInRow.1 {
                //event adds a new event into the current row, update other events in row too
                if event.startInstant > minEndInstantInRow.1 {
                    //put event under an event that ends before it
                    eventRects[currRow][minEndInstantInRow.0].append(event)
                } else {
                    //add event to end of row in a new column
                    eventRects[currRow].append([event,])
                }
            } else {
                //new row created
                currRow += 1
                eventRects.append([[event,]])
            }
            //init max and min end instants
            maxEndInstantInRow = (0, Date.distantPast)
            minEndInstantInRow = (0, Date.distantFuture)
            var col_i = 0
            for col in eventRects[currRow] {
                if let colLast = col.last {
                    if colLast.endInstant > maxEndInstantInRow.1 {
                        maxEndInstantInRow = (col_i, colLast.endInstant)
                    }
                    if colLast.endInstant < minEndInstantInRow.1 {
                        minEndInstantInRow = (col_i, colLast.endInstant)
                    }
                    col_i += 1
                } else {
                    ErrorManager.reportError(throwingFunction: "CalendarDayView.calculateEventRects(events)", loggingMessage: "Could not find colList of eventRects at row: \(currRow)", messageToUser: "Error encountered, please try again later")
                }
            }
        }
        // calculate bounds of each eventRect
        for row in eventRects.indices {
            let width = eventsRenderWidth / Double(eventRects[row].count)
            for col in eventRects[row].indices {
                for i in eventRects[row][col].indices {
                    let event = eventRects[row][col][i]
                    let bounds = CGRect(
                        x: CGFloat(col) * width + eventsXOffset,
                        y: self.yCoordinateBySecond(date.distance(to: event.startInstant)),
                        width: width,
                        height: event.duration * eventHeightPerSecond )

                    self.eventBounds[event.eventId] = bounds
                }
            }
        }
    }
    func yCoordinateByHour(_ hour: Double) -> Double{
        return hour * (eventsRenderHeight / 25) + eventsYOffset
    }
    func yCoordinateBySecond(_ sec: Double) -> Double {
        return yCoordinateByHour(sec / 60 / 60)
    }
    func instantFromYCoordinate(_ y: Double) -> Date {
        return self.date.addingTimeInterval((y - eventsYOffset) / eventHeightPerSecond)
    }
}

struct CalendarEventWithBounds {
    var event: CalendarEventLM
    var bounds: CGRect
    
    init(event: CalendarEventLM, bounds: CGRect) {
        self.event = event
        self.bounds = bounds
    }
    init(_ event: CalendarEventLM, _ bounds: CGRect) {
        self.init(event: event, bounds: bounds)
    }
}
