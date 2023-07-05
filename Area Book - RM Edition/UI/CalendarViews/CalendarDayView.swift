import SwiftUI

struct CalendarDayView: View {
    //@Binding var eventsByDay: [Int: [CalendarEvent]]
    //eventsByDay[day] is organized by the following rules:
    // 1. events with the earliest startInstant are first
    // 2. if both share the same startInstant, events with the latest endInstant are first
    // 3. if both events share the same startInstant and endInstant, the event with the lowest eventId is first
    
    var day: Double
    var eventsManager: CalendarEventsManager
    
    @State var eventViewsManager: CalendarEventViewsManager?
    //@State var eventRects: [[[CalendarEventWithBounds]]] = [] // [row][column][index in column

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
                        Rectangle()
                            .fill(.red.opacity(0.5))
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
                        
                        eventViewsManager?.getCalendarViews()
                        
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
                                
                                let eventsXOffset = 50.0
                                let eventsRenderHeight = 1500.0
                                let eventsRenderWidth = geometry.size.width - eventsXOffset
                                let eventHeightPerSecond = eventsRenderHeight / 25.0 / 60.0 / 60.0
                                let eventsYOffset = eventHeightPerSecond * 60 * 60 / 2.0
                                
                                //print("x-off: \(eventsXOffset)")
                                //print("heightPerSecond: \(eventHeightPerSecond)")
                                eventViewsManager = CalendarEventViewsManager(day: day, eventsManager: eventsManager, eventsRenderWidth: eventsRenderWidth, eventsRenderHeight: eventsRenderHeight, eventsXOffset: eventsXOffset, eventsYOffset: eventsYOffset, eventHeightPerSecond: eventHeightPerSecond)
                                eventViewsManager?.calculateEventRects()
                                reader.scrollTo(6, anchor: .top)
                            }
                        }
                    )
                } // scrollViewReader
            }
        }
    }
    func refreshEventViews() {
        eventViewsManager?.calculateEventRects()
    }
    func startEditCalendarEventWindow(eventId: Int) {
        if editingCalendarEventWindowActive { return }
        editingCalendarEventWindowActive = true
        var _onSubmit =  { (event: CalendarEvent) in
            eventsManager.updateEventData(eventId: eventId, eventData: event)
            editingCalendarEventWindowActive = false
        }
        
        //let vc = EditCalendarEventView(eventId: eventId, eventsManager: eventsManager, _onSubmit: _onSubmit)
        //vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        //self.present(vc, animated: false, completion: nil)
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
struct CalendarEventWithBounds : Hashable {
    var event: CalendarEvent
    var bounds: CGRect?
    
    init(event: CalendarEvent, bounds: CGRect?) {
        self.event = event
        self.bounds = bounds
    }
    init(_ event: CalendarEvent, _ bounds: CGRect?) {
        self.init(event: event, bounds: bounds)
    }
    static func == (lhs: CalendarEventWithBounds, rhs: CalendarEventWithBounds) -> Bool {
        return lhs.event.eventId == rhs.event.eventId
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
        //set proposedNewStartInstant to nearest 15-minute interval
        //print("y-value = \(y)")
        //y = seconds / 60 / 60 * (eventsRenderHeight / 25) + eventsYOffset)
        proposedNewStartInstant = day + (y - yOffSet) / (maxY/25) * 60 * 60
        return nil
    }
    
    func dropEntered(info: DropInfo) {
        isProposingDrop = true
    }
}


/*class CalendarEventDropInfo : NSObject, Codable, NSItemProviderWriting {
    var eventId: Int
    var dropYValue: Int
    
    static var writableTypeIdentifiersForItemProvider: [String] {
            return ["CalendarEventDropInfoObject"]
        }

        func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                completionHandler(data, nil)
            } catch {
                completionHandler(nil, error)
            }
            return nil
        }
    }
    init(_json: String){
        let dict = JSONDecoder().decode(Dictionary, from: _json)
        eventId = Int(dict["eventId"])
        dropYValue = Int(dict["dropYValue"])
    }
} */
