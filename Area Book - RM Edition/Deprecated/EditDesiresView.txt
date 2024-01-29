//
//  CreateDesireView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 10/25/23.
//

import Foundation
import SwiftUI

struct EditDesiresView : View {
    
    @EnvironmentObject var appManager: RMLifePlannerManager
    @Binding var navigationPath: NavigationPath
    @State var title: String = ""
    @State var deadline: Date?
    @State var inspirationalVerb: String = "to accomplish"
    @FocusState var titleIsFocused: Bool
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            /*HStack {
                Text("What do you want")
                    .fontWeight(.black)
                    .font(.title2)
                    .foregroundColor(Colors.textFaint)
                Text("\(inspirationalVerb)?")
                    .fontWeight(.black)
                    .font(.title2)
                    .foregroundColor(Colors.textFaint)
                    .animation(.easeInOut(duration: 1.7), value: inspirationalVerb)
            }.padding()*/
            
            TextField("Your Big-Picture Goal Here...", text: $title)
                .focused($titleIsFocused)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(Colors.textFaint)
                .lineLimit(1)
                .padding()
        }
        VStack (alignment: .center) {
            HStack {
                Button{
                    navigationPath.removeLast()
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(Colors.textBody)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15.0)
                                .fill(Colors.backgroundOffWhite))
                }
                .padding()

                Button{
                    let desire = DesireLM(name: title, userId: GlobalVars.authentication!.user_id)
                    navigationPath.append(desire)
                } label: {
                    Text("Next Step: Short-term Goals!")
                        .font(.subheadline)
                        .foregroundColor(Colors.textBody)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15.0)
                                .fill(Colors.accentColorLight))
                }.padding()

                
            }
            .padding(.horizontal)
        }
        .onTapGesture {
            titleIsFocused = false
        }
        .navigationDestination(for: DesireLM.self) { desire in
            let desireId = appManager.desiresManager.createDesire(desire: desire)
            CreateGoalView(desireId: desireId, navigationPath: $navigationPath)
        }
        /*.onAppear() {
            _ = Timer.scheduledTimer(withTimeInterval: 2.25, repeats: true, block: { _ in
                   inspirationalVerb = getInspirationalVerb()
               })
        }*/
    }
    func submit() {
        let desire = DesireLM(name: title, userId: GlobalVars.authentication!.user_id, dateCreated: Date.now, deadline: deadline)
        navigationPath.append(desire)
    }
    func getInspirationalVerb() -> String {
        let verbs = ["to become", "to do", "to accomplish", "to say", "to know", "to try", "to experience", "to enjoy", "to love", "to see", "to be proud of", "to find", "to discover", "to stop doing", "to start doing", "to keep doing", "to change",  "to learn", "to grow", "to feel", "for your family", "for you", "in 5 years", "forever"]
        while true {
            let choice = verbs.randomElement()!
            if choice != inspirationalVerb {
                return choice
            }
        }
    }
}

struct EditDesiresViewPreview: PreviewProvider {
    static var previews: some View {
        @State var navigationPath = NavigationPath()
        EditDesiresView(navigationPath: $navigationPath)
    }
}
