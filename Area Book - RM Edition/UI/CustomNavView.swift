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
            Spacer()
            Button(action: {
                toDesiresAndGoalsView()
            }){
                VStack {
                    Image(systemName: "chart.bar")
                    Text("Vision")
                }
            }
            Spacer()
            Button(action: {
                toCalendarView()
                
            }){
                VStack {
                    Image(systemName: "calendar")
                    Text("Plan")
                }
            }
            Spacer()
            /*Button(action: {
                toPeopleView()
            }){
                Text("People")
            }*/
            Button(action: {
                toProfileView()
            }){
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
            Spacer()
        }
    }
}

/*struct CustomNavView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView()
    }
}*/
