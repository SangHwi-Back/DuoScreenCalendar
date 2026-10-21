import SwiftUI

public enum AppColor {
    // MARK: - Basic Colors
    case paperBackground
    case cardSurface
    case sunk
    case ink
    case muted
    case line
    case sundayRed
    case saturdayBlue
    case accent
    case accentSoft
    case onAccent
    case scrim
    
    // MARK: - Category Colors
    case work
    case health
    case personal
    
    public func color(colorScheme: ColorScheme) -> Color {
        
        switch self {
        case .paperBackground:
            return colorScheme == .dark ? Color(hex: "#15130F") : Color(hex: "#F6F1E7")
            
        case .cardSurface:
            return colorScheme == .dark ? Color(hex: "#1D1A15") : Color(hex: "#FFFDF8")
            
        case .sunk:
            return colorScheme == .dark ? Color(hex: "#2A2620") : Color(hex: "#ECE4D3")
            
        case .ink:
            return colorScheme == .dark ? Color(hex: "#EDE6D8") : Color(hex: "#22201C")
            
        case .muted:
            return colorScheme == .dark ? Color(hex: "#A8A090") : Color(hex: "#6B655A")
            
        case .line:
            return colorScheme == .dark ? Color(hex: "#37322A") : Color(hex: "#E0D6C2")
            
        case .sundayRed:
            return colorScheme == .dark ? Color(hex: "#F08A72") : Color(hex: "#B83A26")
            
        case .saturdayBlue:
            return colorScheme == .dark ? Color(hex: "#8FB0EA") : Color(hex: "#2C5AA0")
            
        case .accent:
            return colorScheme == .dark ? Color(hex: "#F08A72") : Color(hex: "#B83A26")
            
        case .accentSoft:
            return colorScheme == .dark ? Color(hex: "#3A2620") : Color(hex: "#F6E0D8")
            
        case .onAccent:
            return colorScheme == .dark ? Color(hex: "#1A1410") : Color(hex: "#FFFFFF")
            
        case .scrim:
            return
            colorScheme == .dark ?
            Color(red: 0, green: 0, blue: 0, opacity: 0.55) :
            Color(red: 34/255, green: 32/255, blue: 28/255, opacity: 0.30)
            
        case .work:
            return colorScheme == .dark ? Color(hex: "#9DBBF0") : Color(hex: "#E1E8F4")
            
        case .health:
            return colorScheme == .dark ? Color(hex: "#97CFA3") : Color(hex: "#DDEBDD")
            
        case .personal:
            return colorScheme == .dark ? Color(hex: "#E8B184") : Color(hex: "#F2E3D0")
        }
    }
}

// MARK: - Helper Extensions
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = (int >> 8 & 0xF, int >> 4 & 0xF, int & 0xF, 0xF)
        case 4: // RGBA (16-bit)
            (r, g, b, a) = (int >> 12 & 0xF, int >> 8 & 0xF, int >> 4 & 0xF, int & 0xF)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 0xFF)
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 0xFF)
        }
        self.init(
            red: (Double(r) / Double(255)),
            green: (Double(g) / Double(255)),
            blue: (Double(b) / Double(255)),
            opacity: Double(a) / Double(255)
        )
    }
}
