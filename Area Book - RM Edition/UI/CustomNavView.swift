//
//  CustomNavView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct CustomNavView: View {
    var toDesiresAndGoalsView: () -> Void
    var toCalendarView: () -> Void
    var toPeopleView: () -> Void
    var toProfileView: () -> Void

    var body: some View{
        HStack{
            Button(action: {
                toDesiresAndGoalsView()
            }){
                Text("Desires and Goals") // TODO: make nav buttons have pretty icons
            }
            Button(action: {
                toCalendarView()
            }){
                Text("Calendar") // TODO: make nav buttons have pretty icons
            }
            Button(action: {
                toPeopleView()
            }){
                Text("People") // TODO: make nav buttons have pretty icons
            }
            Button(action: {
                toProfileView()
            }){
                Text("Settings") // TODO: make nav buttons have pretty icons
            }
        }
    }
}

/*struct CustomNavView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView()
    }
}*/
