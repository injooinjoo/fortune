import SwiftUI
import WidgetKit

struct DailyFortuneWidgetView: View {
    var entry: FortuneEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallFortuneView(entry: entry)
        case .systemMedium:
            MediumFortuneView(entry: entry)
        case .systemLarge:
            LargeFortuneView(entry: entry)
        default:
            SmallFortuneView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallFortuneView: View {
    let entry: FortuneEntry
    @Environment(\.colorScheme) var colorScheme

    private var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        ZStack {
            // Simplified background - single color instead of gradient
            ContainerRelativeShape()
                .fill(Color("AccentColor").opacity(0.9))

            VStack(spacing: 8) {
                // Simplified header
                HStack {
                    Text("오늘의 운세")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(textColors.primary)
                    Spacer()
                }

                Spacer()

                // Score
                Text("\(entry.fortuneScore)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(textColors.primary)
                + Text("/100")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(textColors.secondary)

                // Lucky Number
                HStack(spacing: 4) {
                    Image(systemName: "number.circle.fill")
                        .font(.caption2)
                    Text("행운의 숫자: \(entry.luckyNumber)")
                        .font(.caption2)
                }
                .foregroundColor(textColors.secondary)

                Spacer()
            }
            .padding()
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Medium Widget
struct MediumFortuneView: View {
    let entry: FortuneEntry
    @Environment(\.colorScheme) var colorScheme

    private var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("WidgetBackground1"), Color("WidgetBackground2")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            HStack(spacing: 16) {
                // Left: Score
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("오늘의 운세")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(textColors.secondary)

                    Spacer()

                    Text("\(entry.fortuneScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(textColors.primary)
                    + Text("/100")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(textColors.secondary)

                    Spacer()

                    // Lucky Items
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "paintpalette.fill")
                                .font(.caption2)
                            Text(entry.luckyColor)
                                .font(.caption2)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "number.circle.fill")
                                .font(.caption2)
                            Text("숫자 \(entry.luckyNumber)")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(textColors.secondary)
                }

                Divider()
                    .background(textColors.divider)

                // Right: Message
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.fortuneMessage)
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(textColors.primary)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(textColors.tertiary)
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Large Widget
struct LargeFortuneView: View {
    let entry: FortuneEntry
    @Environment(\.colorScheme) var colorScheme

    private var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color("WidgetBackground1"), Color("WidgetBackground2")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                        Text("오늘의 운세")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption)
                        .foregroundColor(textColors.tertiary)
                }
                .foregroundColor(textColors.primary)

                // Score Section
                HStack(spacing: 20) {
                    // Score
                    VStack(alignment: .leading, spacing: 4) {
                        Text("운세 점수")
                            .font(.caption)
                            .foregroundColor(textColors.secondary)
                        Text("\(entry.fortuneScore)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(textColors.primary)
                        + Text("/100")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(textColors.secondary)
                    }

                    Spacer()

                    // Lucky Items
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "paintpalette.fill")
                                .font(.body)
                                .foregroundColor(textColors.icon)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("행운의 색상")
                                    .font(.caption2)
                                    .foregroundColor(textColors.tertiary)
                                Text(entry.luckyColor)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(textColors.primary)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "number.circle.fill")
                                .font(.body)
                                .foregroundColor(textColors.icon)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("행운의 숫자")
                                    .font(.caption2)
                                    .foregroundColor(textColors.tertiary)
                                Text("\(entry.luckyNumber)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(textColors.primary)
                            }
                        }
                    }
                }

                Divider()
                    .background(textColors.divider)

                // Fortune Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘의 메시지")
                        .font(.caption)
                        .foregroundColor(textColors.secondary)

                    Text(entry.fortuneMessage)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(textColors.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                if let detailedFortune = entry.detailedFortune {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("상세 운세")
                            .font(.caption)
                            .foregroundColor(textColors.secondary)

                        Text(detailedFortune)
                            .font(.footnote)
                            .foregroundColor(textColors.secondary)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                // Call to Action
                HStack {
                    Spacer()
                    Text("자세히 보기 ›")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(textColors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(textColors.backgroundOverlay)
                        )
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "fortune://daily"))
    }
}

// MARK: - Preview
struct DailyFortuneWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DailyFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            DailyFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            DailyFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}