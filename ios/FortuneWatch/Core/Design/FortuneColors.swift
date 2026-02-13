import SwiftUI

// MARK: - Fortune Colors

/// Design system colors for Fortune Watch app
enum FortuneColors {

    // MARK: - Grade Colors

    /// Get color for fortune grade
    static func gradeColor(for grade: String) -> Color {
        switch grade {
        case "대길": return Color(hex: "22C55E") // Green
        case "길": return Color(hex: "3B82F6")   // Blue
        case "평": return Color(hex: "EAB308")   // Yellow
        case "흉": return Color(hex: "F97316")   // Orange
        case "대흉": return Color(hex: "EF4444") // Red
        default: return .secondary
        }
    }

    // MARK: - Score Colors

    /// Get color based on score (0-100)
    static func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return Color(hex: "22C55E") // Green
        case 60..<80: return Color(hex: "3B82F6")  // Blue
        case 40..<60: return Color(hex: "EAB308") // Yellow
        case 20..<40: return Color(hex: "F97316") // Orange
        default: return Color(hex: "EF4444")      // Red
        }
    }

    /// Get gradient for score
    static func scoreGradient(for score: Int) -> LinearGradient {
        let color = scoreColor(for: score)
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Biorhythm Colors

    static let bioPhysical = Color(hex: "F97316")    // Orange
    static let bioEmotional = Color(hex: "EC4899")   // Pink
    static let bioIntellectual = Color(hex: "3B82F6") // Blue

    // MARK: - Theme Colors

    static let primary = Color(hex: "8B5CF6")        // Purple
    static let secondary = Color(hex: "6366F1")      // Indigo
    static let accent = Color(hex: "F59E0B")         // Amber
    static let background = Color(hex: "18181B")     // Zinc-900
    static let surface = Color(hex: "27272A")        // Zinc-800
    static let surfaceElevated = Color(hex: "3F3F46") // Zinc-700

    // MARK: - Lucky Item Colors

    /// Parse lucky color string to Color
    static func luckyColor(from colorName: String) -> Color {
        let normalized = colorName.lowercased()
        switch normalized {
        case "빨강", "빨간색", "red": return .red
        case "주황", "주황색", "orange": return .orange
        case "노랑", "노란색", "yellow": return .yellow
        case "초록", "녹색", "green": return .green
        case "파랑", "파란색", "blue": return .blue
        case "남색", "indigo": return .indigo
        case "보라", "보라색", "purple": return .purple
        case "분홍", "핑크", "pink": return .pink
        case "흰색", "하양", "white": return .white
        case "검정", "검은색", "black": return Color(hex: "374151")
        case "회색", "gray": return .gray
        case "갈색", "brown": return .brown
        case "금색", "gold": return Color(hex: "FFD700")
        case "은색", "silver": return Color(hex: "C0C0C0")
        default: return .purple
        }
    }

    // MARK: - Time Slot Colors

    static let morning = Color(hex: "FBBF24")   // Amber-400
    static let afternoon = Color(hex: "F97316") // Orange-500
    static let evening = Color(hex: "6366F1")   // Indigo-500

    static func timeSlotColor(for slot: String) -> Color {
        switch slot.lowercased() {
        case "오전", "morning": return morning
        case "오후", "afternoon": return afternoon
        case "저녁", "evening": return evening
        default: return .secondary
        }
    }
}

// MARK: - Color Extension

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
