import SwiftUI
import WidgetKit

// MARK: - Complication Entry

struct FortuneComplicationEntry: TimelineEntry {
    let date: Date
    let score: Int
    let grade: String
    let message: String
    let gradeEmoji: String
    let isPlaceholder: Bool

    // NEW: Additional data for enhanced complications
    let timeSlotName: String
    let timeSlotScore: Int
    let luckyColor: String
    let bioOverallScore: Int

    static var placeholder: FortuneComplicationEntry {
        FortuneComplicationEntry(
            date: Date(),
            score: 85,
            grade: "길",
            message: "오늘 하루도 좋은 일이 가득할 거예요",
            gradeEmoji: "✨",
            isPlaceholder: true,
            timeSlotName: "오후",
            timeSlotScore: 80,
            luckyColor: "보라",
            bioOverallScore: 75
        )
    }

    static var empty: FortuneComplicationEntry {
        FortuneComplicationEntry(
            date: Date(),
            score: 0,
            grade: "-",
            message: "앱을 열어주세요",
            gradeEmoji: "⭐",
            isPlaceholder: false,
            timeSlotName: "",
            timeSlotScore: 0,
            luckyColor: "",
            bioOverallScore: 0
        )
    }

    // Helper to get score color
    var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .yellow
        case 20..<40: return .orange
        default: return .red
        }
    }
}

// MARK: - Timeline Provider

struct FortuneComplicationProvider: TimelineProvider {
    private let appGroupId = "group.com.beyond.fortune"

    func placeholder(in context: Context) -> FortuneComplicationEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FortuneComplicationEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FortuneComplicationEntry>) -> Void) {
        let entry = loadEntry()

        // 다음 시간대 변경 시점에 업데이트
        let nextUpdate = nextTimeSlotChange()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> FortuneComplicationEntry {
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return .empty
        }

        let score = defaults.integer(forKey: "overall_score")
        let grade = defaults.string(forKey: "overall_grade") ?? ""
        let message = defaults.string(forKey: "overall_message") ?? ""

        // NEW: Load additional data
        let timeSlotName = defaults.string(forKey: "timeslot_name") ?? ""
        let timeSlotScore = defaults.integer(forKey: "timeslot_score")
        let luckyColor = defaults.string(forKey: "lucky_color") ?? ""
        let bioOverallScore = defaults.integer(forKey: "bio_overall_score")

        if score == 0 {
            return .empty
        }

        let gradeEmoji: String = {
            switch grade {
            case "대길": return "🌟"
            case "길": return "✨"
            case "평": return "⭐"
            case "흉": return "🌥️"
            case "대흉": return "🌧️"
            default: return "✨"
            }
        }()

        return FortuneComplicationEntry(
            date: Date(),
            score: score,
            grade: grade,
            message: message,
            gradeEmoji: gradeEmoji,
            isPlaceholder: false,
            timeSlotName: timeSlotName,
            timeSlotScore: timeSlotScore,
            luckyColor: luckyColor,
            bioOverallScore: bioOverallScore
        )
    }

    private func nextTimeSlotChange() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)

        var nextHour: Int
        if hour < 6 {
            nextHour = 6
        } else if hour < 12 {
            nextHour = 12
        } else if hour < 18 {
            nextHour = 18
        } else {
            nextHour = 6 // 다음날 6시
        }

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = nextHour
        components.minute = 0
        components.second = 0

        var nextDate = calendar.date(from: components) ?? now

        // 다음날인 경우
        if nextHour == 6 && hour >= 18 {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }

        return nextDate
    }
}

// MARK: - Circular Complication View

struct CircularComplicationView: View {
    let entry: FortuneComplicationEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                Text(entry.gradeEmoji)
                    .font(.system(size: 16))
                Text("\(entry.score)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
        }
    }
}

// MARK: - Rectangular Complication View

struct RectangularComplicationView: View {
    let entry: FortuneComplicationEntry

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(entry.gradeEmoji)
                    Text("오늘 운세")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                Text("\(entry.score)점 \(entry.grade)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Score Gauge
            Gauge(value: Double(entry.score), in: 0...100) {
                EmptyView()
            }
            .gaugeStyle(.accessoryCircular)
            .scaleEffect(0.7)
        }
    }
}

// MARK: - Inline Complication View

struct InlineComplicationView: View {
    let entry: FortuneComplicationEntry

    var body: some View {
        Text("\(entry.gradeEmoji) 운세 \(entry.score)점")
    }
}

// MARK: - Corner Complication View (NEW)

struct CornerComplicationView: View {
    let entry: FortuneComplicationEntry

    var body: some View {
        ZStack {
            // Score arc
            Circle()
                .trim(from: 0, to: CGFloat(entry.score) / 100)
                .stroke(
                    entry.scoreColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 0) {
                Text(entry.gradeEmoji)
                    .font(.system(size: 10))
                Text("\(entry.score)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
        }
    }
}

// MARK: - Extra Large Complication View (Smart Stack) (NEW)

struct ExtraLargeComplicationView: View {
    let entry: FortuneComplicationEntry

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text(entry.gradeEmoji)
                    .font(.title3)
                Text("오늘의 운세")
                    .font(.headline)
                Spacer()
            }

            // Score with gauge
            HStack(spacing: 12) {
                // Score Gauge
                Gauge(value: Double(entry.score), in: 0...100) {
                    Text("\(entry.score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .gaugeStyle(.accessoryCircular)
                .tint(entry.scoreColor)

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.grade)
                        .font(.title3.weight(.semibold))

                    if !entry.timeSlotName.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("\(entry.timeSlotName) \(entry.timeSlotScore)점")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            // Message preview
            if !entry.message.isEmpty {
                Text(entry.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Complication Widget

struct FortuneComplication: Widget {
    let kind: String = "FortuneComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneComplicationProvider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("오늘의 운세")
        .description("오늘의 운세 점수를 확인하세요")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner  // NEW
        ])
    }
}

// MARK: - Extra Large Complication Widget (Smart Stack) (NEW)

@available(watchOS 10.0, *)
struct FortuneSmartStackComplication: Widget {
    let kind: String = "FortuneSmartStackComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneComplicationProvider()) { entry in
            ExtraLargeComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("운세 상세")
        .description("운세 점수와 상세 정보를 확인하세요")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Complication Entry View

struct ComplicationEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: FortuneComplicationEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularComplicationView(entry: entry)
        case .accessoryRectangular:
            RectangularComplicationView(entry: entry)
        case .accessoryInline:
            InlineComplicationView(entry: entry)
        case .accessoryCorner:
            CornerComplicationView(entry: entry)
        default:
            CircularComplicationView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    FortuneComplication()
} timeline: {
    FortuneComplicationEntry.placeholder
}
