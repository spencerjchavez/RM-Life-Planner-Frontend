
struct DesireCategory{
    var name: String
    var userId: Double
    var colorR: Double
    var colorG: Double
    var colorB: Double
    var progress: Double
    
    init(name: String, userId: Double, colorR: Double, colorG: Double, colorB: Double, progress: Double) {
        self.name = name
        self.userId = userId
        self.colorR = colorR
        self.colorB = colorB
        self.colorG = colorG
        self.progress = progress
    }
    
    init(_ name: String, _ userId: Double, _ colorR: Double, _ colorG: Double, _ colorB: Double, _ progress: Double) {
        self.init(name: name, userId: userId, colorR: colorR, colorG: colorG, colorB: colorB, progress: progress)
    }
}
