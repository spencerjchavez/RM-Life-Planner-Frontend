//
//  CalendarView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct CalendarView: View {
    @State var isSelected: Bool
    let calendarStyles = ["day", "week", "month"]
    @State var selectedOption = "day"
    var body: some View{
        VStack{
            HStack{
                Button(action: {}){
                    Image(systemName: "line.3.horizontal")
                        .font(.title)
                        .foregroundColor(.black)
                }.padding()
                HStack{
                    Picker("view by:", selection: $selectedOption) {
                        ForEach(calendarStyles, id: \.self) { x in
                            Text(x).foregroundColor(x == selectedOption ? .red : .black)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Button(action: {}){
                    Image(systemName: "magnifyingglass")
                        .font(.body)
                        .foregroundColor(.black)
                }.padding()
            }
            AsyncImage(url: URL(string: "https://preview.redd.it/04oaqwdhhd881.jpg?width=857&format=pjpg&auto=webp&v=enabled&s=7e5c91ae92c4714619f2e4a09ea25cca252b0871"))
            { image in image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "doc.text.image")
                    .font(.largeTitle)
            }
            //todo stuff
            HStack{
                VStack{
                    Text("Today's to do items").font(.body)
                    Toggle(isOn: $isSelected){Text("todo item #1")}
                    Toggle(isOn: $isSelected){Text("todo item #2")}
                    Toggle(isOn: $isSelected){Text("todo item #3")}
                    Toggle(isOn: $isSelected){Text("todo item #4")}
                    Toggle(isOn: $isSelected){Text("todo item #5")}
                    
                }
                VStack{
                    Text("This week's to do items").font(.body)
                    Toggle(isOn: $isSelected){Text("todo item #1")}
                    Toggle(isOn: $isSelected){Text("todo item #2")}
                    Toggle(isOn: $isSelected){Text("todo item #3")}
                    Toggle(isOn: $isSelected){Text("todo item #4")}
                    Toggle(isOn: $isSelected){Text("todo item #5")}
                    
                }
            }.padding()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(isSelected: false)
    }
}
