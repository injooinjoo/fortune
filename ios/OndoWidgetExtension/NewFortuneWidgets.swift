import WidgetKit
import SwiftUI

// MARK: - Overall Widget Provider

struct OverallWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> OverallEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (OverallEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        let (overall, _, _, _) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        completion(overall ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<OverallEntry>) -> Void) {
        let manager = UnifiedWidgetDataManager.shared
        let (overall, _, _, _) = manager.loadFromHomeWidget()
        let displayState = manager.getDisplayState()
        let engagementMessage = manager.getEngagementMessage() ?? "오늘의 운세 미리보기 🔮"

        var entry: OverallEntry
        if let overall = overall, !overall.isPlaceholder {
            switch displayState {
            case .today:
                entry = overall
            case .yesterday:
                entry = OverallEntry.yesterday(
                    score: overall.score,
                    grade: overall.grade,
                    message: overall.message,
                    description: overall.description,
                    engagementMessage: engagementMessage
                )
            case .empty:
                entry = .empty
            }
        } else {
            entry = .empty
        }

        // Refresh more frequently for engagement states (30 min vs 1 hour)
        let refreshMinutes = entry.showEngagement ? 30 : 60
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Category Widget Provider

struct CategoryWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CategoryEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (CategoryEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        let (_, category, _, _) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        completion(category ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CategoryEntry>) -> Void) {
        let manager = UnifiedWidgetDataManager.shared
        let (_, category, _, _) = manager.loadFromHomeWidget()
        let displayState = manager.getDisplayState()

        var entry: CategoryEntry
        if let category = category, !category.isPlaceholder {
            switch displayState {
            case .today:
                entry = category
            case .yesterday:
                let engagementMessage = manager.getCategoryEngagementMessage(for: category.categoryKey)
                entry = CategoryEntry.yesterday(
                    categoryKey: category.categoryKey,
                    name: category.name,
                    score: category.score,
                    message: category.message,
                    icon: category.icon,
                    engagementMessage: engagementMessage
                )
            case .empty:
                entry = .empty
            }
        } else {
            entry = .empty
        }

        // Refresh more frequently for engagement states (30 min vs 1 hour)
        let refreshMinutes = entry.showEngagement ? 30 : 60
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - TimeSlot Widget Provider

struct TimeSlotWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeSlotEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeSlotEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        let (_, _, timeSlot, _) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        completion(timeSlot ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeSlotEntry>) -> Void) {
        var entries: [TimeSlotEntry] = []

        let (_, _, timeSlot, _) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        let currentEntry = timeSlot ?? .empty
        entries.append(currentEntry)

        // Create entries for time slot changes
        let calendar = Calendar.current
        let now = Date()

        // Add entries for each time slot transition
        let timeSlotHours = [6, 12, 18] // morning, afternoon, evening
        for hour in timeSlotHours {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = 0

            if let transitionDate = calendar.date(from: components), transitionDate > now {
                let transitionEntry = TimeSlotEntry(
                    date: transitionDate,
                    name: getTimeSlotName(for: hour),
                    score: currentEntry.score,
                    message: currentEntry.message,
                    icon: getTimeSlotIcon(for: hour),
                    isPlaceholder: false
                )
                entries.append(transitionEntry)
            }
        }

        // Refresh at midnight
        var nextDay = calendar.dateComponents([.year, .month, .day], from: now)
        nextDay.day! += 1
        nextDay.hour = 0
        nextDay.minute = 0
        let nextUpdate = calendar.date(from: nextDay) ?? now.addingTimeInterval(3600)

        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getTimeSlotName(for hour: Int) -> String {
        switch hour {
        case 6..<12: return "오전"
        case 12..<18: return "오후"
        default: return "저녁"
        }
    }

    private func getTimeSlotIcon(for hour: Int) -> String {
        switch hour {
        case 6..<12: return "🌅"
        case 12..<18: return "☀️"
        default: return "🌙"
        }
    }
}

// MARK: - Lotto Widget Provider

struct LottoWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LottoEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (LottoEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }

        let (_, _, _, lotto) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        completion(lotto ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LottoEntry>) -> Void) {
        let (_, _, _, lotto) = UnifiedWidgetDataManager.shared.loadFromHomeWidget()
        let entry = lotto ?? .empty

        // Refresh daily
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Overall Widget View

struct OverallWidgetView: View {
    var entry: OverallEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        switch family {
        case .systemSmall:
            SmallOverallView(entry: entry, textColors: textColors)
        case .systemMedium:
            MediumOverallView(entry: entry, textColors: textColors)
        default:
            SmallOverallView(entry: entry, textColors: textColors)
        }
    }
}

struct SmallOverallView: View {
    let entry: OverallEntry
    let textColors: WidgetTextColors

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.gradeEmoji)
                    .font(.title2)
                Text("총운")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textColors.primary)
                Spacer()
            }

            // Score (with opacity for yesterday state)
            HStack(alignment: .bottom, spacing: 4) {
                if entry.displayState == .empty {
                    Text("?")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(textColors.secondary)
                } else {
                    Text("\(entry.score)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(WidgetColors.scoreColor(for: entry.score))
                        .opacity(entry.displayState == .yesterday ? 0.5 : 1.0)
                }
                Text("점")
                    .font(.subheadline)
                    .foregroundColor(textColors.secondary)
                    .padding(.bottom, 6)
            }

            Spacer()

            // Show engagement badge or grade
            if entry.showEngagement, let message = entry.engagementMessage {
                HStack {
                    Text(message)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
            } else {
                HStack {
                    Text(entry.grade)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(textColors.backgroundOverlay)
                        .cornerRadius(8)
                        .foregroundColor(textColors.primary)
                    Spacer()
                }
            }
        }
    }
}

struct MediumOverallView: View {
    let entry: OverallEntry
    let textColors: WidgetTextColors

    var body: some View {
        HStack(spacing: 16) {
            // Left: Score
            VStack(alignment: .center, spacing: 4) {
                Text(entry.gradeEmoji)
                    .font(.system(size: 36))

                Text("\(entry.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(WidgetColors.scoreColor(for: entry.score))

                Text(entry.grade)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(textColors.backgroundOverlay)
                    .cornerRadius(8)
                    .foregroundColor(textColors.primary)
            }
            .frame(width: 100)

            // Right: Message
            VStack(alignment: .leading, spacing: 8) {
                Text("오늘의 총운")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textColors.primary)

                Text(entry.message)
                    .font(.subheadline)
                    .foregroundColor(textColors.secondary)
                    .lineLimit(2)

                Spacer()

                if let description = entry.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(textColors.tertiary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Category Widget View

struct CategoryWidgetView: View {
    var entry: CategoryEntry
    @Environment(\.colorScheme) var colorScheme

    var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.icon)
                    .font(.title2)
                Text(entry.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textColors.primary)
                Spacer()
            }

            // Score (with opacity for yesterday state)
            HStack(alignment: .bottom, spacing: 4) {
                if entry.displayState == .empty {
                    Text("?")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(textColors.secondary)
                } else {
                    Text("\(entry.score)")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(WidgetColors.scoreColor(for: entry.score))
                        .opacity(entry.displayState == .yesterday ? 0.5 : 1.0)
                }
                Text("점")
                    .font(.subheadline)
                    .foregroundColor(textColors.secondary)
                    .padding(.bottom, 4)
            }

            Spacer()

            // Show engagement badge or message
            if entry.showEngagement, let message = entry.engagementMessage {
                Text(message)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Text(entry.message)
                    .font(.caption)
                    .foregroundColor(textColors.secondary)
                    .lineLimit(2)
            }
        }
    }
}

// MARK: - TimeSlot Widget View

struct TimeSlotWidgetView: View {
    var entry: TimeSlotEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Left: Icon and time
            VStack(alignment: .center, spacing: 8) {
                Text(entry.icon)
                    .font(.system(size: 40))

                Text(entry.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textColors.primary)

                Text("\(entry.score)점")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(WidgetColors.scoreColor(for: entry.score))
            }
            .frame(width: 80)

            // Right: Message
            VStack(alignment: .leading, spacing: 8) {
                Text("시간대 운세")
                    .font(.caption)
                    .foregroundColor(textColors.tertiary)

                Text(entry.message)
                    .font(.subheadline)
                    .foregroundColor(textColors.secondary)
                    .lineLimit(3)

                Spacer()

                // Time slot indicator
                HStack(spacing: 8) {
                    TimeSlotIndicator(name: "오전", isActive: entry.name == "오전")
                    TimeSlotIndicator(name: "오후", isActive: entry.name == "오후")
                    TimeSlotIndicator(name: "저녁", isActive: entry.name == "저녁")
                }
            }

            Spacer()
        }
    }
}

struct TimeSlotIndicator: View {
    let name: String
    let isActive: Bool

    var body: some View {
        Text(name)
            .font(.system(size: 10))
            .fontWeight(isActive ? .bold : .regular)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isActive ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isActive ? .blue : .gray)
            .cornerRadius(4)
    }
}

// MARK: - Lotto Widget View

struct LottoWidgetView: View {
    var entry: LottoEntry
    @Environment(\.colorScheme) var colorScheme

    var textColors: WidgetTextColors {
        WidgetTextColors(colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("🎱")
                    .font(.title2)
                Text("행운의 숫자")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(textColors.primary)
                Spacer()
            }

            Spacer()

            // Numbers
            if entry.numbers.isEmpty {
                Text("앱을 열어 번호를 확인하세요")
                    .font(.caption)
                    .foregroundColor(textColors.secondary)
            } else {
                HStack(spacing: 8) {
                    ForEach(entry.displayNumbers, id: \.self) { number in
                        LottoBall(number: number)
                    }
                }
            }

            Spacer()

            // Footer
            Text("오늘의 추천 번호")
                .font(.caption2)
                .foregroundColor(textColors.tertiary)
        }
    }
}

struct LottoBall: View {
    let number: Int

    var ballColor: Color {
        switch number {
        case 1...10: return .yellow
        case 11...20: return .blue
        case 21...30: return .red
        case 31...40: return .gray
        default: return .green
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(ballColor)
                .frame(width: 32, height: 32)
                .shadow(color: ballColor.opacity(0.3), radius: 2, x: 0, y: 2)

            Text("\(number)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Widget Configurations

struct OndoOverallWidget: Widget {
    let kind: String = "OndoOverallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OverallWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                OverallWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                OverallWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("총운")
        .description("오늘의 총운 점수와 등급을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct OndoCategoryWidget: Widget {
    let kind: String = "OndoCategoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CategoryWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                CategoryWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CategoryWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("카테고리 운세")
        .description("연애/금전/직장/학업/건강 중 선택한 운세를 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

struct OndoTimeSlotWidget: Widget {
    let kind: String = "OndoTimeSlotWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSlotWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                TimeSlotWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TimeSlotWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("시간대 운세")
        .description("현재 시간대의 운세를 확인하세요 (오전/오후/저녁)")
        .supportedFamilies([.systemMedium])
    }
}

struct OndoLottoWidget: Widget {
    let kind: String = "OndoLottoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LottoWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                LottoWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LottoWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("행운의 숫자")
        .description("오늘의 행운의 숫자 5개를 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

struct NewFortuneWidgets_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverallWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Overall Small")

            OverallWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Overall Medium")

            CategoryWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Category")

            TimeSlotWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("TimeSlot")

            LottoWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Lotto")
        }
    }
}
