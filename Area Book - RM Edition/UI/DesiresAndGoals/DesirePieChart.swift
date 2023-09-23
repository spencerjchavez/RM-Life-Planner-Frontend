//
//  DesirePieChart.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 6/6/23.
//

import SwiftUI

struct DesirePieChart: View {
    @EnvironmentObject var appManager: RMLifePlannerManager
    let goalAchievingReport: GoalAchievingReport
    var pie_sections: [(CustomPieSection, CustomPieSection)] = []
    init(report: GoalAchievingReport) {
        self.goalAchievingReport = report
        let degreesPerDesire = 360.0/Double(goalAchievingReport.desires.count)
        var base_angle = 360.0
        for desire in goalAchievingReport.desires {
            let progress_angle = base_angle - degreesPerDesire + (degreesPerDesire * (report.desiresProgress[desire.desireId] ?? 0))
            let color = GlobalVars.userPreferences!.getColorOfPriority(desire.priorityLevel)
            pie_sections.append((CustomPieSection(angle: Angle(degrees: base_angle), color: color), CustomPieSection(angle: Angle(degrees: progress_angle), color: color)))
            base_angle -= degreesPerDesire
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            ForEach(pie_sections.indices, id: \.self) { index in
                let (base_section, progress_section) = pie_sections[index]
                base_section
                    .fill(base_section.color)
                    .brightness(0.45)
                progress_section
                    .fill(progress_section.color)
                base_section.stroke(.black, lineWidth: 2.5)
            }.mask(Circle())
            Circle()
                .stroke(.black, lineWidth: 2.5)
            Circle()
                .padding(70)
                .foregroundColor(.white)
            Circle()
                .stroke(.black, lineWidth: 2.5)
                .padding(70)
            VStack{
                Text(Int((goalAchievingReport.totalProgress * 100).rounded()).description + "%")
                    .foregroundColor(.black)
                    .font(Font.custom("Helvetica-Bold", size: 32))
                Text("completed")
                    .foregroundColor(.black)
                    .font(.title)
            }
        }
        .scaledToFill()
    }
}
struct CustomPieSection: Shape{
    var angle: Angle
    var color: Color
    
    init(angle: Angle, color: Color) {
        self.angle = angle
        self.color = color
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if angle.degrees >= 360 {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            return path
        }
        path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        
        let radius: Double = rect.maxX - rect.midX
        var line_length: Double
        var theta = angle.radians.truncatingRemainder(dividingBy: Double.pi / 2.0)
        if theta <= Double.pi / 4 {
            line_length = radius / cos(theta)
        } else {
            theta = Double.pi / 2 - theta
            line_length = radius / cos(theta)
        }

        var x_or_y = sqrt(pow(line_length, 2) - pow(radius, 2))
        var section = 0
        if angle.degrees >= 315 {
            path.addLine(to: CGPoint(x: rect.midX - x_or_y, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            section = 4
        } else if angle.degrees >= 225 {
            if angle.degrees > 270 { x_or_y *= -1 }
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + x_or_y))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            section = 3
        } else if angle.degrees >= 135 {
            if angle.degrees > 180 { x_or_y *= -1 }
            path.addLine(to: CGPoint(x: rect.midX + x_or_y, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            section = 2
        } else if angle.degrees >= 45 {
            if angle.degrees < 90 { x_or_y *= -1 }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + x_or_y))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            section = 1
        } else {
            path.addLine(to: CGPoint(x: rect.midX + x_or_y, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            section = 0
        }

        //work the path around the edge of the rectangle
        switch (section){
        case 4:
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            fallthrough
        case 3:
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            fallthrough
        case 2:
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            fallthrough
        case 1:
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            fallthrough
        default:
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        }
        return path
    }
}
