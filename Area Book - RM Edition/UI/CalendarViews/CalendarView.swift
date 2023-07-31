//
//  CalendarView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var eventsManager: CalendarEventsManager
    @State var isSelected: Bool
    let calendarStyles = ["day", "week", "month"]
    @State var selectedOption = "day"
    @State var selectedDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date.now)!.timeIntervalSince1970
    @State var selectedIndex = 10
    var events: [CalendarEvent] =
    [CalendarEvent(eventId: 1, name: "my second event is very cool, like me", startInstant: Date.now.addingTimeInterval(60 * 60 * -5).timeIntervalSince1970, endInstant: Date.now.addingTimeInterval(60 * 60 * -2).timeIntervalSince1970),
        CalendarEvent(eventId: 2, name: "my second event is very cool, like me", startInstant: Date.now.addingTimeInterval(60 * 60 * -5).timeIntervalSince1970),
        CalendarEvent(eventId: 3, name: "my second event is very cool, like me", startInstant: Date.now.addingTimeInterval(60 * 60 * -3.5).timeIntervalSince1970),
        CalendarEvent(eventId: 6, name: "my second event is very cool, like me", startInstant: Date.now.addingTimeInterval(60 * 60 * -3.5).timeIntervalSince1970),
        CalendarEvent(eventId: 4, name: "my first event!", startInstant: Date.now.timeIntervalSince1970),
        CalendarEvent(eventId: 5, name: "my second event is very cool, like me", startInstant: Date.now.addingTimeInterval(60 * 60 * 0.3).timeIntervalSince1970)]
    
    //var eventsManager: CalendarEventsManager
    init(isSelected: Bool) {
        self.isSelected = isSelected
        try! eventsManager.addEvents(events: events)
    }
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack{
                    Button(action: {}){
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text(Date(timeIntervalSince1970: Double(selectedDay)).formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    HStack{
                        Picker("view by:", selection: $selectedOption) {
                            ForEach(calendarStyles, id: \.self) { x in
                                Text(x).foregroundColor(x == selectedOption ? .red : .black)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    Spacer()
                    Button(action: {}){
                        Image(systemName: "magnifyingglass")
                            .font(.body)
                            .foregroundColor(.black)
                    }
                }
                TabView(selection: $selectedIndex) {
                    ForEach(0..<1000, id: \.self) { i in
                        let toAdd = DateComponents(day: i - 10)
                        let date  = Calendar.current.date(byAdding: toAdd, to: Date.now)!
                        let day = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!.timeIntervalSince1970
                        CalendarDayView(day: day, eventsManager: eventsManager)
                            .tag(i)
                    }
                }
                .onChange(of: selectedIndex, perform: { i in
                    let toAdd = DateComponents(day: selectedIndex - 10)
                    selectedDay = Calendar.current.date(byAdding: toAdd, to: Date.now)!.timeIntervalSince1970
                    
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                //todo stuff
                HStack{
                    ScrollView{
                        Text("Today's to do items").font(.body)
                        Toggle(isOn: $isSelected){Text("todo item #1")}
                        Toggle(isOn: $isSelected){Text("todo item #2")}
                        Toggle(isOn: $isSelected){Text("todo item #3")}
                        Toggle(isOn: $isSelected){Text("todo item #4")}
                        Toggle(isOn: $isSelected){Text("todo item #5")}
                    }
                    ScrollView{
                        Text("This week's to do items").font(.body)
                        Toggle(isOn: $isSelected){Text("todo item #1")}
                        Toggle(isOn: $isSelected){Text("todo item #2")}
                        Toggle(isOn: $isSelected){Text("todo item #3")}
                        Toggle(isOn: $isSelected){Text("todo item #4")}
                        Toggle(isOn: $isSelected){Text("todo item #5")}
                    }
                }.frame(height: geometry.size.height / 3)
            }.padding()
        }.onAppear{
            
        }
    }
}
