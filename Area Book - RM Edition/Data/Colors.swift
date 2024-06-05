//
//  Colors.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/19/23.
//

import Foundation
import SwiftUI


struct Colors {
    static let lightBlue = Color("LightBlue")
    static let lightGray = Color("LightGray")
    static let coolMint = Color("CoolMint")
    
    static let accentColorLight = Color("AccentColorLight")
    static let accentColorDark = Color("AccentColorDark")

    static let backgroundWhite = Color("BackgroundWhite")
    static let backgroundOffWhite = Color("BackgroundOffWhite")
    static let backgroundGray = Color("BackgroundGray")

    
    static let textTitle = Color("TextTitle")
    static let textFaint = Color("TextFaint")
    static let textSubtitle = Color("TextSubtitle")
    static let textBody = Color("TextBody")
    
    // Colors for user priority management
    static let priority1 = Color("PriorityColor1")
    static let priority2 = Color("PriorityColor2")
    static let priority3 = Color("PriorityColor3")
    static let priority4 = Color("PriorityColor4")
    static let priority5 = Color("PriorityColor5")
    static let priority6 = Color("PriorityColor6")
}


extension Color {
    func hexString() -> String {
        return self.description
    }
    
    init(fromHex hex: String) {
        var colorString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "0x", with: "").uppercased()
        let rIndex = colorString.startIndex
        let gIndex = colorString.index(rIndex, offsetBy: 2)
        let bIndex = colorString.index(gIndex, offsetBy: 2)

        let red = Double("0x".appending(String(colorString[rIndex..<gIndex]))) ?? 0.0 / 255.0
        let green = Double("0x".appending(String(colorString[gIndex..<bIndex]))) ?? 0.0 / 255.0
        let blue = Double("0x".appending(String(colorString[bIndex..<colorString.endIndex]))) ?? 0.0 / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
