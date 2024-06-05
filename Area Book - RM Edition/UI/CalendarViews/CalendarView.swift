//
//  CalendarView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appManager: RMLifePlannerManager
    let calendarStyles = ["day", "week", "month"]
    @State var selectedOption = "day"
    @State var selectedIndex = 100
    @State var dateDisplayText: String = ""
    @State private var navigationPath = NavigationPath()
    var dateOnIndex100 = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date.now)
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            GeometryReader{ geometry in
                VStack{
                    HStack{
                        Button(action: {}){
                            Image(systemName: "line.3.horizontal")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text(dateDisplayText)
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
                            let toAdd = DateComponents(day: i - 100)
                            let date  = Calendar.current.date(byAdding: toAdd, to: Date.now) ?? Date.now
                            CalendarDayView(date: date, navigationPath: $navigationPath)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onAppear(perform: {
                        dateDisplayText = dateOnIndex100?.formatted(date: .abbreviated, time: .omitted) ?? ""
                    })
                    .onChange(of: selectedIndex, perform: { index in
                        dateDisplayText = Calendar.current.date(byAdding: .day, value: index - 100, to: dateOnIndex100 ?? Date.now)?.formatted(date: .abbreviated, time: .omitted) ?? ""
                    })
                }
                .padding()
                .navigationDestination(for: CalendarEventModificationView.self, destination: { view in
                    view
                })
            }
        }
    }
}


