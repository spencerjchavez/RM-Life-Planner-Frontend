//
//  CircularProgressView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 1/11/24.
//

import SwiftUI

struct CircularProgressView: View {
    
    var percent: Double
    var accentColor: Color
    var backgroundColor: Color
    var widthRatio: Double
    
    //circle at the top of the circle
    @State var circle1Position: CGPoint = CGPoint(x: 0.0, y: 0.0)
    //end circle marking progress
    @State var circle2Position: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var endcapCircleDiameter: Double = 0.0
    
    init(amountAccomplished: Double, amountPlanned: Double, accentColor: Color, backgroundColor: Color) {
        self.percent = amountAccomplished / amountPlanned
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.widthRatio = 0.16
    }
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                Circle()
                    .foregroundColor(self.backgroundColor)
                Circle()
                    .trim(from: 0, to: self.percent)
                    .rotation(Angle(degrees: -90 + 360 * (1 - self.percent)))
                    .stroke(lineWidth: reader.size.width * widthRatio)
                    .frame(width: reader.size.width * (1 - self.widthRatio))
                    .position(x: reader.size.width/2,y: reader.size.height/2)
                    .foregroundColor(self.accentColor)
                Circle()
                    .frame(width: endcapCircleDiameter)
                    .position(circle1Position)
                    .foregroundColor(self.accentColor)
                Circle()
                    .frame(width: endcapCircleDiameter)
                    .position(circle2Position)
                    .foregroundColor(self.accentColor)
                    .onAppear {
                        self.endcapCircleDiameter = self.widthRatio * reader.size.width
                        let radius = reader.size.width/2 - self.endcapCircleDiameter/2
                        circle1Position = CGPoint(x: reader.size.width / 2,
                                                  y: self.endcapCircleDiameter/2)
                        
                        let angle = Angle(degrees: self.percent * 360)
                        let x = cos(angle.radians + Double.pi/2 ) * radius + reader.size.width / 2
                        let y = reader.size.height / 2 - sin(angle.radians + Double.pi/2) * radius
                        circle2Position = CGPoint(x: x, y: y)
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    
    struct AngleShape: Shape {
        
        let percent: Double
        
        init(_ percent: Double) {
            self.percent = percent
        }
        
        func path(in rect: CGRect) -> Path {
            let angle = Angle(degrees: max(0, self.percent * 360 - 15))
            let outer_radius = rect.midX
            let inner_radius = outer_radius * 0.8
            let end_x = cos(angle.radians + Double.pi/2 ) * (outer_radius + inner_radius) / 2 + rect.midX
            let end_y = rect.midX - sin(angle.radians + Double.pi/2) * (outer_radius + inner_radius) / 2
            let end_point = CGPoint(x: end_x, y: end_y)
            let center_point = CGPoint(x: rect.midX, y: rect.midX)
            
            
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minX))
            path.addArc(center: center_point, radius: outer_radius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: -1 * angle.degrees - 90), clockwise: true)
            
            return path
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(amountAccomplished: 14, amountPlanned: 15, accentColor: Colors.priority1, backgroundColor: Colors.backgroundOffWhite)
            .aspectRatio(1, contentMode: .fit)
    }
}
