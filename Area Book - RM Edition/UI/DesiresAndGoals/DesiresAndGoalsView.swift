//
//  DesiresAndGoalsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct DesiresAndGoalsView: View {
    var ex_categories = [DesireCategory("work", 0, 1, 0, 0, 0.75),
                         DesireCategory("school", 0, 0, 0, 1, 0.40),
                         DesireCategory("be good", 0, 1, 1, 0.01, 1.0),
                         DesireCategory("save money", 0, 0.85, 0.15, 0.9, 0.17),
                         DesireCategory("love my neighbor!", 0, 0.31, 0.78, 0.09, 0.35)]
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                //Spacer()
                DesirePieChart(categories: ex_categories)
                //Spacer()
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

struct DesiresAndGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        DesiresAndGoalsView()
    }
}
