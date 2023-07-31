import SwiftUI

struct CalendarDayView: View {
    //@Binding var eventsByDay: [Int: [CalendarEvent]]
    //eventsByDay[day] is organized by the following rules:
    // 1. events with the earliest startInstant are first
    // 2. if both share the same startInstant, events with the latest endInstant are first
    // 3. if both events share the same startInstant and endInstant, the event with the lowest eventId is first
    let eventsXOffset = 50.0
    @State var eventsYOffset = 0.0
    @State var eventsRenderWidth = 0.0
    @State var eventsRenderHeight = 1500.0
    @State var eventHeightPerSecond = 0.0
    
    var day: Double
    @EnvironmentObject var eventsManager: CalendarEventsManager
    //@State var eventsWithBounds: [CalendarEventWithBounds] = []
    //var eventViews: [CalendarEventView] = []
    @State var eventBounds: [Int: CGRect] = [:] // by eventId
    //@ObservedObject var eventRects = EventRects()
    
    @State var editingCalendarEventWindowActive: Bool = false
    @State var editingCalendarEventId: Int = -1
    //@State var editingCalendarEventListener: (_ event: CalendarEvent) -> Void
        
    @State var isProposingDrop: Bool = false
    @State var proposedNewStartInstant: Double = -1
    var previewEventDropYValue : Double {
        (proposedNewStartInstant - day) / 60 / 60 * eventsRenderHeight / 25 + eventsYOffset
    }
    var proposedNewStartTimeString: String {
        return Date(timeIntervalSince1970: proposedNewStartInstant).formatted(date: .omitted, time: .shortened)
    }
    var eventDropPreviewText: String {
        return "move event to" + proposedNewStartInstant.description
    }
    
    var body: some View {
        GeometryReader { globalGeometry in
            ScrollView{
                ScrollViewReader{ reader in
                    ZStack() {
                        Color.clear
                        Rectangle() //user to capture drop events
                            .fill(.white)
                            .frame(width: globalGeometry.size.width, height: eventsRenderHeight)
                            .onDrop(of: [.url], delegate: CalendarDayViewEventDropDelegate(eventsManager: eventsManager, isProposingDrop: $isProposingDrop, proposedNewStartInstant: $proposedNewStartInstant, day: day, yOffSet: eventsYOffset, maxY: eventsRenderHeight))
                        ForEach(0..<24, id: \.self) { hour in
                            ZStack {
                                HStack{
                                    Text(hour == 0 ? "12 am" : (hour < 12 ? hour.description + " am" : (hour == 12 ? "12 pm" : (hour - 12).description + " pm")))
                                    Rectangle()
                                        .fill(.gray)
                                        .frame(height: 2.0)
                                }
                            }
                            .position(x: globalGeometry.size.width / 2, y: Double(hour) * (eventsRenderHeight / 25) + eventsYOffset)
                            .allowsHitTesting(false)
                            
                        }
                        
                        ForEach(eventsManager.getEventsOnDay(day: Int(day)), id: \.eventId) { event in
                            let bounds = eventBounds[event.eventId] ?? .zero
                            CalendarEventView(event: event)
                                .frame(width: bounds.width,
                                       height: bounds.height,
                                       alignment: .center)
                                 .position(x: bounds.midX,
                                           y: bounds.midY)
                                 .onTapGesture {
                                     startEditCalendarEventWindow(eventId: event.eventId)
                                 }
                                 .onDrag{
                                     self.eventsManager.eventIdToDrop = event.eventId
                                     return NSItemProvider(contentsOf: URL(string: event.eventId.description))!
                                  } preview: {
                                      CalendarEventView(event: event)
                                          .frame(width: bounds.width, height: bounds.height, alignment: .center)
                                 }
                        }
                        .allowsHitTesting(!isProposingDrop)
                        .onChange(of: eventsManager.eventsByDay) { _ in
                            calculateEventRects()
                        }
                        
                        //drop preview time view
                        if isProposingDrop {
                            HStack{
                                Text(proposedNewStartTimeString)
                                    .foregroundColor(.green)
                                Rectangle()
                                    .fill(.black)
                                    .frame(height: 2.0)
                            }
                            .position(x: globalGeometry.size.width / 2, y: previewEventDropYValue)
                        }
                    }
                    .frame(height: eventsRenderHeight + eventsYOffset)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                reader.scrollTo(0, anchor: .top)
                                eventsRenderWidth = geometry.size.width - eventsXOffset
                                eventHeightPerSecond = eventsRenderHeight / 25.0 / 60.0 / 60.0
                                eventsYOffset = eventHeightPerSecond * 60 * 60 / 2.0
                                //print("x-off: \(eventsXOffset)")
                                //print("heightPerSecond: \(eventHeightPerSecond)")
                                calculateEventRects()
                                reader.scrollTo(6, anchor: .top)
                            }
                        }
                    )
                } // scrollViewReader
            }
        }
    }
    func calculateEventRects() {
        // calculate rectangles
        print("recalculate the bounds")
        var eventRects: [[[CalendarEvent]]] = []
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
            //update max and min end instants
            maxEndInstantInRow = (0, 0.0)
            minEndInstantInRow = (0, Double.infinity)
            var col_i = 0
            for col in eventRects[currRow] {
                if col.last!.endInstant > maxEndInstantInRow.1 {
                    maxEndInstantInRow = (col_i, col.last!.endInstant)
                }
                if col.last!.endInstant < minEndInstantInRow.1 {
                    minEndInstantInRow = (col_i, col.last!.endInstant)
                }
                col_i += 1
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
                        y: (event.startInstant - event.startDay) *  eventHeightPerSecond + eventsYOffset,
                        width: width,
                        height: (event.endInstant - event.startInstant) * eventHeightPerSecond)

                    self.eventBounds[event.eventId] = bounds
                }
            }
        }
    }
    func startEditCalendarEventWindow(eventId: Int) {
        if editingCalendarEventWindowActive { return }
        editingCalendarEventWindowActive = true
        var _onSubmit =  { (event: CalendarEvent) in
            eventsManager.updateEventData(eventId: eventId, eventData: event)
            editingCalendarEventWindowActive = false
        }
        
        let vc = EditCalendarEventView(eventId: eventId, eventsManager: eventsManager)
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: false, completion: nil)
    }
}
struct CalendarEventWithBounds : Hashable {
    var event: CalendarEvent
    var bounds: CGRect
    
    init(event: CalendarEvent, bounds: CGRect) {
        self.event = event
        self.bounds = bounds
    }
    init(_ event: CalendarEvent, _ bounds: CGRect) {
        self.init(event: event, bounds: bounds)
    }
    static func == (lhs: CalendarEventWithBounds, rhs: CalendarEventWithBounds) -> Bool {
        return lhs.event.eventId == rhs.event.eventId && lhs.bounds == rhs.bounds
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(event)
        hasher.combine(bounds)
    }
}
class CalendarDayViewEventDropDelegate : NSObject, DropDelegate {
    //var eventIdToDrop: Int = -1
    @Binding var proposedNewStartInstant: Double
    @Binding var isProposingDrop: Bool
    let day: Double
    let eventsManager: CalendarEventsManager
    let yOffSet: Double
    let maxY: Double
    
    init(eventsManager: CalendarEventsManager, isProposingDrop: Binding<Bool>, proposedNewStartInstant: Binding<Double>, day: Double, yOffSet: Double, maxY: Double) {
        self._proposedNewStartInstant = proposedNewStartInstant
        self._isProposingDrop = isProposingDrop
        self.eventsManager = eventsManager
        self.day = day
        self.yOffSet = yOffSet
        self.maxY = maxY
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let eventIdToDrop = eventsManager.eventIdToDrop
        print("perform drop on eventId: \(eventIdToDrop)")
        if eventIdToDrop == -1 { return true }
        //let y = info.location.y
        try! eventsManager.updateEventStartInstant(eventId: eventIdToDrop, newStartInstant: proposedNewStartInstant)
        eventsManager.eventIdToDrop = -1
        isProposingDrop = false
        return true
    }
    
    func dropExited(info: DropInfo) {
        print("cancelled drop on eventId: \(eventsManager.eventIdToDrop)")
        isProposingDrop = false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        isProposingDrop = true
        let y = info.location.y
        //print("y-value = \(y)")
        //y = seconds / 60 / 60 * (eventsRenderHeight / 25) + eventsYOffset)
        var newStartInstant = day + (y - yOffSet) / (maxY/25) * 60 * 60
        //round newStartInstant to nearest 15 minute interval
        var date = Date(timeIntervalSince1970: newStartInstant)
        var dc = Calendar.current.dateComponents([.minute], from: date)
        var newMinute = round(Double(dc.minute ?? 0) / 15.0) * 15
        
        date = (Calendar.current.date(bySetting: .minute, value: 0, of: date)!.addingTimeInterval(TimeInterval(60 * newMinute)))
        proposedNewStartInstant = date.timeIntervalSince1970
        return nil
    }
    
    func dropEntered(info: DropInfo) {
        isProposingDrop = true
    }
}
