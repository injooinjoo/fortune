import SwiftUI

// MARK: - Fortune Typography

/// Typography styles for Fortune Watch app
enum FortuneTypography {

    // MARK: - Title Styles

    static let largeTitle = Font.system(size: 20, weight: .bold, design: .rounded)
    static let title = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 13, weight: .semibold, design: .rounded)

    // MARK: - Body Styles

    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodyBold = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let callout = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Caption Styles

    static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
    static let captionBold = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let footnote = Font.system(size: 12, weight: .regular, design: .rounded)

    // MARK: - Score Styles

    static let scoreHero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let scoreLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let scoreMedium = Font.system(size: 22, weight: .bold, design: .rounded)
    static let scoreSmall = Font.system(size: 16, weight: .bold, design: .rounded)

    // MARK: - Emoji Styles

    static let emojiLarge = Font.system(size: 36)
    static let emojiMedium = Font.system(size: 24)
    static let emojiSmall = Font.system(size: 18)
}

// MARK: - View Modifier for Typography

struct FortuneTextStyle: ViewModifier {
    let font: Font
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
    }
}

extension View {
    func fortuneTextStyle(_ font: Font, color: Color = .primary) -> some View {
        modifier(FortuneTextStyle(font: font, color: color))
    }
}
