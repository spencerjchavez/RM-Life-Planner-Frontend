//
//  CalendarEventView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/6/23.
//

import SwiftUI

struct CalendarEventView : View {
    var event: CalendarEventLM
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(Colors.coolMint)
            
            /*RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2.0)
                .padding(0.7)
                .foregroundColor(.mint) */
            HStack {
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding()
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity)
                    
            }
        }
    }
}
