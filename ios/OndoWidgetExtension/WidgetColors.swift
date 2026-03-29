import SwiftUI

extension Color {
    // MARK: - Widget Background Colors
    static let widgetBackground1 = Color("WidgetBackground1")
    static let widgetBackground2 = Color("WidgetBackground2")
    static let loveWidgetBackground1 = Color("LoveWidgetBackground1")
    static let loveWidgetBackground2 = Color("LoveWidgetBackground2")
    static let activityBackground = Color("ActivityBackground")

    // MARK: - Text Colors
    static let widgetPrimaryText = Color("WidgetPrimaryText")
    static let widgetSecondaryText = Color("WidgetSecondaryText")
    static let widgetAccent = Color("WidgetAccent")
}

// MARK: - Dynamic Widget Text Colors
struct WidgetTextColors {
    let colorScheme: ColorScheme

    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }

    // Primary text color - high contrast
    var primary: Color {
        colorScheme == .dark ? .white : Color(white: 0.1)
    }

    // Secondary text color - medium contrast
    var secondary: Color {
        colorScheme == .dark ? .white.opacity(0.8) : Color(white: 0.3)
    }

    // Tertiary text color - low contrast
    var tertiary: Color {
        colorScheme == .dark ? .white.opacity(0.6) : Color(white: 0.5)
    }

    // Divider color
    var divider: Color {
        colorScheme == .dark ? .white.opacity(0.3) : Color(white: 0.2).opacity(0.3)
    }

    // Background overlay for buttons/indicators
    var backgroundOverlay: Color {
        colorScheme == .dark ? .white.opacity(0.2) : Color(white: 0.1).opacity(0.15)
    }

    // Icon color
    var icon: Color {
        colorScheme == .dark ? .white.opacity(0.8) : Color(white: 0.2)
    }
}

// MARK: - Widget Color Set
// These colors should be defined in Assets.xcassets with both light and dark variants
struct WidgetColors {
    // Background Gradients
    static let dailyFortuneGradient = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.4, blue: 0.9),
            Color(red: 0.3, green: 0.5, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let loveFortuneGradient = LinearGradient(
        colors: [
            Color(red: 0.9, green: 0.3, blue: 0.5),
            Color(red: 1.0, green: 0.4, blue: 0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let activityGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.1, blue: 0.2),
            Color(red: 0.2, green: 0.2, blue: 0.3)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Score Colors
    static func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100:
            return Color.green
        case 60..<80:
            return Color.blue
        case 40..<60:
            return Color.orange
        case 20..<40:
            return Color.yellow
        default:
            return Color.red
        }
    }
    
    // Compatibility Colors
    static func compatibilityColor(for score: Int) -> Color {
        switch score {
        case 80...100:
            return Color.pink
        case 60..<80:
            return Color.purple
        case 40..<60:
            return Color.orange
        default:
            return Color.gray
        }
    }
}

// MARK: - Color Assets Reference
/*
 Required color assets in Assets.xcassets:
 
 1. WidgetBackground1 - Primary widget background color
 2. WidgetBackground2 - Secondary widget background color
 3. LoveWidgetBackground1 - Love widget primary background
 4. LoveWidgetBackground2 - Love widget secondary background
 5. ActivityBackground - Live Activity background color
 6. WidgetPrimaryText - Primary text color for widgets
 7. WidgetSecondaryText - Secondary text color for widgets
 8. WidgetAccent - Accent color for interactive elements
 
 Each color should have:
 - Light appearance variant
 - Dark appearance variant
 */