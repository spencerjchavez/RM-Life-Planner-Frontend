//
//  DesiresAndGoalsProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/21/23.
//

import Foundation
import SwiftUI

struct DesiresAndGoalsProgressContainerView: View {
    var body: some View {
        VStack {
            GeometryReader { reader in
                Text("9/17 - 9/23")
                    .font(.subheadline)
                    .padding()
                /*HStack {
                    VStack {
                        DesireAndGoalsProgressView()
                        Spacer()
                    }
                    .frame(width: reader.size.width / 2)
                    .padding(.horizontal, 5)
                    VStack {
                        
                        Spacer()
                    }
                    .frame(width: reader.size.width / 2)
                    .padding(.horizontal, 5)
                } */
                Spacer()
            }
        }
    }
}
