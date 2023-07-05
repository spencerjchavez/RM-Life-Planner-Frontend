//
//  DesiresAndGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct DesiresAndGoalsView: View {
    var categories = [DesireCategory("find a job", 0, Color(red: 45.0/255, green: 115.0/255, blue: 59.0/255), 0.75),
                      DesireCategory("get all A's in school", 0, Color(red: 67.0/255, green: 191.0/255, blue: 224.0/255), 0.40),
                      DesireCategory("be a good brother", 0, Color(red: 170.00/255, green: 45.0/255, blue: 100.0/255), 0.80),
                      //128 29 88
                      DesireCategory("save money", 0, Color(red: 0.0/255, green: 65.0/255, blue: 230.0/255), 0.47),
                      DesireCategory("become a scriptorian", 0, Color(red: 151.0/255, green: 30.0/255, blue: 255.0/255), 0.35)]
    @State var revealNewEntryField = false
    @State var entry_text: String = ""
    @State var notes: [(String, Date)] = [("Feeling good! Been very productive, but it's been hard to accomplish everything I set out to do lately with all the school and work stuff", Date(timeIntervalSince1970: TimeInterval(1581418811))), ("I had a really good bean burrito today", Date(timeIntervalSince1970: TimeInterval(1581500811)))]
    var body: some View {
        ScrollView(){
            VStack(alignment: .center) {
                Text("THIS WEEK'S PROGRESS")
                    .foregroundColor(.black)
                    .font(.title)
                DesirePieChart(categories: categories)
                Text("Your Desires:")
                    .font(.title2)
                ForEach(categories.indices, id: \.self) { i in
                    HStack (){
                        Rectangle()
                            .fill(categories[i].color)
                            .aspectRatio(1.0, contentMode: .fit)
                            .fixedSize()
                        Text(Int((categories[i].progress * 100).rounded()).description + "% - " +  categories[i].name)
                        Spacer()
                    }
                    .font(.body)
                    .fixedSize()
                }
                Button(action: { revealNewEntryField.toggle() }){
                    ZStack{
                        if revealNewEntryField {
                            Text("Hide")
                                .padding(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .stroke(.black, lineWidth: 1.5))
                        } else {
                            Text("Add a new journal entry")
                                .padding(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .stroke(.black, lineWidth: 1.5))
                        }
                        
                    }
                }
                if revealNewEntryField {
                    VStack{
                        ZStack{
                            TextField("How is the week going? Journal your progress!", text: $entry_text, axis: .vertical)
                                .lineLimit(20)
                                .padding (5)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 2)
                        }
                        HStack{
                            Spacer()
                            Button(action: { submitEntry()} ) {
                                Text("Add entry")
                            }
                        }
                    }
                }
                VStack{
                    Text("Entries from the week:")
                    ForEach(notes.indices, id: \.self) { i in
                        var (note, date) = notes[i]
                        ZStack{
                            VStack {
                                HStack{
                                    Text(note)
                                        .font(.body)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    Text(date.formatted(date: .complete, time: .omitted))
                                        .foregroundColor(.gray)
                                }
                            }.padding(5)
                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                .stroke(.black, lineWidth: 1.8)
                        }
                    }
                }
                
            }
            .padding()
        }
    }
    func submitEntry() -> Void {
        notes.append((entry_text, Date.now))
        entry_text = ""
        self.revealNewEntryField = false
    }
}
