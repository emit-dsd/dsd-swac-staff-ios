import SwiftUI

extension Color {
    // Uncategorized
    static let black      = Color(hex: "000000")  // Black
    static let white      = Color(hex: "FFFFFF")  // White
    static let red        = Color(hex: "FF3665")  // Red
    static let yellow     = Color(hex: "DAAA00")  // Yellow
    static let orange     = Color(hex: "CC8315")  // Orange
    static let green      = Color(hex: "00D600")  // Green
    
    // Primary
    static let Primary800 = Color(hex: "0068A6")  // Primary 800
    static let Primary700 = Color(hex: "2C70F3")  // Primary 700
    static let Primary600 = Color(hex: "00A0DD")  // Primary 600
    static let Primary500 = Color(hex: "2C70F3")  // Primary 500
    static let Primary100 = Color(hex: "DBE7FF")  // Primary 100
    
    // Neutral
    static let Neutral800 = Color(hex: "222222")  // Neutral 800
    static let Neutral500 = Color(hex: "888888")  // Neutral 500
    static let Neutral300 = Color(hex: "E5E5E5")  // Neutral 300
    static let Neutral200 = Color(hex: "F5F5F5")  // Neutral 200
    static let Neutral100 = Color(hex: "FBFBFB")  // Neutral 100
    
    
    static let lightTeal = Color(hex: "E8FBFF")
    static let lightBlue = Color(hex: "F6FBFF")
    static let notificationRed = Color(hex: "FF3564")
    static let successBackground = Color(hex: "EEFFEE")
    static let warningYellow = Color(hex: "FFC107")
    static let blueberry = Color(hex: "3C7CF4")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
