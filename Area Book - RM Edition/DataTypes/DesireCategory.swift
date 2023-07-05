import SwiftUI
struct DesireCategory{
    var name: String
    var userId: Double
    var color: Color
    var progress: Double
    
    init(name: String, userId: Double, color: Color, progress: Double) {
        self.name = name
        self.userId = userId
        self.color = color
        self.progress = progress
    }
    
    init(_ name: String, _ userId: Double, _ color: Color, _ progress: Double) {
        self.init(name: name, userId: userId, color: color, progress: progress)
    }
}
