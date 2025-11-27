import WidgetKit
import SwiftUI

// MARK: - Favorites Fortune Entry
struct FavoritesFortuneEntry: TimelineEntry {
    let date: Date
    let fortuneType: String
    let icon: String
    let title: String
    let score: String?
    let message: String?
    let extraData: [String: String]
    let isPlaceholder: Bool
    let totalFavorites: Int
    let currentIndex: Int

    static var placeholder: FavoritesFortuneEntry {
        FavoritesFortuneEntry(
            date: Date(),
            fortuneType: "daily",
            icon: "✨",
            title: "일일운세",
            score: "85",
            message: "오늘은 좋은 일이 생길 예정입니다",
            extraData: ["luckyColor": "파란색", "luckyNumber": "7"],
            isPlaceholder: true,
            totalFavorites: 3,
            currentIndex: 0
        )
    }

    static var empty: FavoritesFortuneEntry {
        FavoritesFortuneEntry(
            date: Date(),
            fortuneType: "empty",
            icon: "⭐",
            title: "즐겨찾기",
            score: nil,
            message: "즐겨찾기한 운세가 없습니다\n운세를 즐겨찾기에 추가해보세요",
            extraData: [:],
            isPlaceholder: false,
            totalFavorites: 0,
            currentIndex: 0
        )
    }
}

// MARK: - Favorites Fortune Provider
struct FavoritesFortuneProvider: TimelineProvider {
    private let appGroupIdentifier = "group.com.beyond.fortune"
    private let favoritesKey = "fortune_favorites"
    private let rollingIndexKey = "widget_rolling_index"
    private let fortuneCachePrefix = "widget_fortune_cache_"

    // Rolling interval: 1 minute
    private let rollingInterval: TimeInterval = 60

    func placeholder(in context: Context) -> FavoritesFortuneEntry {
        FavoritesFortuneEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoritesFortuneEntry) -> ()) {
        if context.isPreview {
            completion(FavoritesFortuneEntry.placeholder)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let entry = self.loadCurrentFavorite() ?? FavoritesFortuneEntry.placeholder
            DispatchQueue.main.async {
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesFortuneEntry>) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var entries: [FavoritesFortuneEntry] = []
            let favorites = self.loadFavorites()

            guard !favorites.isEmpty else {
                // No favorites - show empty state
                let timeline = Timeline(entries: [FavoritesFortuneEntry.empty], policy: .after(Date().addingTimeInterval(3600)))
                DispatchQueue.main.async {
                    completion(timeline)
                }
                return
            }

            let currentIndex = self.getCurrentIndex()
            let now = Date()

            // Create entries for the next hour (60 entries, 1 per minute)
            for i in 0..<60 {
                let entryDate = now.addingTimeInterval(Double(i) * self.rollingInterval)
                let index = (currentIndex + i) % favorites.count
                let fortuneType = favorites[index]

                if let entry = self.loadFortuneEntry(
                    for: fortuneType,
                    at: entryDate,
                    index: index,
                    total: favorites.count
                ) {
                    entries.append(entry)
                }
            }

            // If no entries could be loaded, show empty state
            if entries.isEmpty {
                entries.append(FavoritesFortuneEntry.empty)
            }

            // Save updated index for next timeline
            self.saveCurrentIndex((currentIndex + 60) % max(favorites.count, 1))

            // Refresh timeline after 1 hour
            let nextUpdate = now.addingTimeInterval(3600)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdate))

            DispatchQueue.main.async {
                completion(timeline)
            }
        }
    }

    // MARK: - Data Loading

    private func loadFavorites() -> [String] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return []
        }
        return sharedDefaults.stringArray(forKey: favoritesKey) ?? []
    }

    private func getCurrentIndex() -> Int {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return 0
        }
        return sharedDefaults.integer(forKey: rollingIndexKey)
    }

    private func saveCurrentIndex(_ index: Int) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }
        sharedDefaults.set(index, forKey: rollingIndexKey)
    }

    private func loadFortuneEntry(for type: String, at date: Date, index: Int, total: Int) -> FavoritesFortuneEntry? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let jsonString = sharedDefaults.string(forKey: "\(fortuneCachePrefix)\(type)"),
              let jsonData = jsonString.data(using: .utf8),
              let data = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            // Return placeholder for this fortune type if no cached data
            return FavoritesFortuneEntry(
                date: date,
                fortuneType: type,
                icon: getIconForType(type),
                title: getTitleForType(type),
                score: nil,
                message: "운세 데이터를 불러오는 중...",
                extraData: [:],
                isPlaceholder: false,
                totalFavorites: total,
                currentIndex: index
            )
        }

        return FavoritesFortuneEntry(
            date: date,
            fortuneType: type,
            icon: data["icon"] as? String ?? getIconForType(type),
            title: data["title"] as? String ?? getTitleForType(type),
            score: data["score"] as? String,
            message: data["message"] as? String,
            extraData: extractExtraData(from: data, for: type),
            isPlaceholder: false,
            totalFavorites: total,
            currentIndex: index
        )
    }

    private func loadCurrentFavorite() -> FavoritesFortuneEntry? {
        let favorites = loadFavorites()
        guard !favorites.isEmpty else {
            return FavoritesFortuneEntry.empty
        }

        let currentIndex = getCurrentIndex() % favorites.count
        let fortuneType = favorites[currentIndex]

        return loadFortuneEntry(for: fortuneType, at: Date(), index: currentIndex, total: favorites.count)
    }

    // MARK: - Type-specific Data Extraction

    private func extractExtraData(from data: [String: Any], for type: String) -> [String: String] {
        var extraData: [String: String] = [:]

        switch type {
        case "daily":
            if let luckyColor = data["luckyColor"] as? String { extraData["luckyColor"] = luckyColor }
            if let luckyNumber = data["luckyNumber"] as? String { extraData["luckyNumber"] = luckyNumber }
            if let percentile = data["percentile"] as? String { extraData["percentile"] = percentile }

        case "love":
            if let goodDay = data["goodDay"] as? String { extraData["goodDay"] = goodDay }

        case "career":
            if let luckyTime = data["luckyTime"] as? String { extraData["luckyTime"] = luckyTime }

        case "investment":
            if let lottoNumbers = data["lottoNumbers"] as? [String] {
                extraData["lottoNumbers"] = lottoNumbers.prefix(5).joined(separator: ", ")
            }
            if let sector = data["sector"] as? String { extraData["sector"] = sector }

        case "mbti":
            if let mbtiType = data["mbtiType"] as? String { extraData["mbtiType"] = mbtiType }
            if let energyLevel = data["energyLevel"] as? String { extraData["energyLevel"] = energyLevel }
            if let mood = data["mood"] as? String { extraData["mood"] = mood }

        case "tarot":
            if let cardName = data["cardName"] as? String { extraData["cardName"] = cardName }
            if let interpretation = data["interpretation"] as? String { extraData["interpretation"] = interpretation }

        case "biorhythm":
            if let physical = data["physical"] as? String { extraData["physical"] = physical }
            if let emotional = data["emotional"] as? String { extraData["emotional"] = emotional }
            if let intellectual = data["intellectual"] as? String { extraData["intellectual"] = intellectual }

        case "compatibility":
            if let partnerName = data["partnerName"] as? String { extraData["partnerName"] = partnerName }

        case "health":
            if let warningArea = data["warningArea"] as? String { extraData["warningArea"] = warningArea }

        case "dream":
            if let symbol = data["symbol"] as? String { extraData["symbol"] = symbol }
            if let meaning = data["meaning"] as? String { extraData["meaning"] = meaning }

        case "lucky-items":
            if let items = data["items"] as? [String] {
                extraData["items"] = items.prefix(3).joined(separator: ", ")
            }

        case "traditional-saju":
            if let summary = data["summary"] as? String { extraData["summary"] = summary }
            if let todayFortune = data["todayFortune"] as? String { extraData["todayFortune"] = todayFortune }

        case "face-reading":
            if let features = data["features"] as? String { extraData["features"] = features }

        case "talent":
            if let area = data["area"] as? String { extraData["area"] = area }
            if let activity = data["activity"] as? String { extraData["activity"] = activity }

        case "blind-date":
            if let bestDay = data["bestDay"] as? String { extraData["bestDay"] = bestDay }
            if let advice = data["advice"] as? String { extraData["advice"] = advice }

        case "ex-lover":
            if let possibility = data["possibility"] as? String { extraData["possibility"] = possibility }
            if let advice = data["advice"] as? String { extraData["advice"] = advice }

        case "moving":
            if let bestDirection = data["bestDirection"] as? String { extraData["bestDirection"] = bestDirection }
            if let bestDate = data["bestDate"] as? String { extraData["bestDate"] = bestDate }

        case "pet-compatibility":
            if let petType = data["petType"] as? String { extraData["petType"] = petType }

        case "family-harmony":
            if let advice = data["advice"] as? String { extraData["advice"] = advice }

        case "time":
            if let currentPeriod = data["currentPeriod"] as? String { extraData["currentPeriod"] = currentPeriod }

        case "avoid-people":
            if let warningType = data["warningType"] as? String { extraData["warningType"] = warningType }
            if let description = data["description"] as? String { extraData["description"] = description }
            if let advice = data["advice"] as? String { extraData["advice"] = advice }

        default:
            break
        }

        return extraData
    }

    // MARK: - Type Helpers

    private func getIconForType(_ type: String) -> String {
        let icons: [String: String] = [
            "daily": "✨",
            "love": "💖",
            "career": "💼",
            "investment": "📈",
            "mbti": "🧠",
            "tarot": "🃏",
            "biorhythm": "📊",
            "compatibility": "💑",
            "health": "🏥",
            "dream": "🌙",
            "lucky-items": "🍀",
            "traditional-saju": "🔮",
            "face-reading": "👤",
            "talent": "⭐",
            "blind-date": "💘",
            "ex-lover": "💔",
            "moving": "🏠",
            "pet-compatibility": "🐾",
            "family-harmony": "👨‍👩‍👧‍👦",
            "time": "⏰",
            "avoid-people": "🚫"
        ]
        return icons[type] ?? "🔮"
    }

    private func getTitleForType(_ type: String) -> String {
        let titles: [String: String] = [
            "daily": "일일운세",
            "love": "연애운",
            "career": "직업운",
            "investment": "투자운",
            "mbti": "MBTI 운세",
            "tarot": "타로",
            "biorhythm": "바이오리듬",
            "compatibility": "궁합",
            "health": "건강운",
            "dream": "꿈해몽",
            "lucky-items": "행운 아이템",
            "traditional-saju": "전통 사주",
            "face-reading": "관상",
            "talent": "재능운",
            "blind-date": "소개팅운",
            "ex-lover": "재회운",
            "moving": "이사운",
            "pet-compatibility": "반려동물 궁합",
            "family-harmony": "가족 화목",
            "time": "시간대별 운세",
            "avoid-people": "피해야 할 사람"
        ]
        return titles[type] ?? type
    }
}

// MARK: - Favorites Fortune Widget View
struct FavoritesFortuneWidgetView: View {
    var entry: FavoritesFortuneEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallFavoritesView(entry: entry)
        case .systemMedium:
            MediumFavoritesView(entry: entry)
        case .systemLarge:
            LargeFavoritesView(entry: entry)
        default:
            SmallFavoritesView(entry: entry)
        }
    }
}

// MARK: - Small Widget View
struct SmallFavoritesView: View {
    let entry: FavoritesFortuneEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with icon and title
            HStack {
                Text(entry.icon)
                    .font(.title2)
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }

            // Score if available
            if let score = entry.score {
                HStack(spacing: 4) {
                    Text(score)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(scoreColor(for: Int(score) ?? 0))
                    Text("점")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Message
            if let message = entry.message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Rolling indicator
            if entry.totalFavorites > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<min(entry.totalFavorites, 5), id: \.self) { i in
                        Circle()
                            .fill(i == entry.currentIndex % min(entry.totalFavorites, 5) ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    if entry.totalFavorites > 5 {
                        Text("+\(entry.totalFavorites - 5)")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Medium Widget View
struct MediumFavoritesView: View {
    let entry: FavoritesFortuneEntry

    var body: some View {
        HStack(spacing: 12) {
            // Left side - Score and icon
            VStack(alignment: .center, spacing: 8) {
                Text(entry.icon)
                    .font(.system(size: 40))

                if let score = entry.score {
                    VStack(spacing: 2) {
                        Text(score)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(scoreColor(for: Int(score) ?? 0))
                        Text("점")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 80)

            // Right side - Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.bold)

                // Type-specific extra data
                extraDataView

                Spacer()

                // Message
                if let message = entry.message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Rolling indicator
                rollingIndicator
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var extraDataView: some View {
        switch entry.fortuneType {
        case "daily":
            if let luckyColor = entry.extraData["luckyColor"],
               let luckyNumber = entry.extraData["luckyNumber"] {
                HStack(spacing: 12) {
                    Label(luckyColor, systemImage: "paintpalette")
                        .font(.caption)
                    Label(luckyNumber, systemImage: "number")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

        case "investment":
            if let lottoNumbers = entry.extraData["lottoNumbers"] {
                HStack {
                    Image(systemName: "ticket")
                        .foregroundColor(.orange)
                    Text(lottoNumbers)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

        case "biorhythm":
            HStack(spacing: 8) {
                if let physical = entry.extraData["physical"] {
                    VStack {
                        Text("신체")
                            .font(.system(size: 8))
                        Text(physical)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                if let emotional = entry.extraData["emotional"] {
                    VStack {
                        Text("감정")
                            .font(.system(size: 8))
                        Text(emotional)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                if let intellectual = entry.extraData["intellectual"] {
                    VStack {
                        Text("지성")
                            .font(.system(size: 8))
                        Text(intellectual)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
            .foregroundColor(.secondary)

        case "mbti":
            if let mbtiType = entry.extraData["mbtiType"] {
                Text(mbtiType)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }

        case "tarot":
            if let cardName = entry.extraData["cardName"] {
                Text(cardName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.29, green: 0.0, blue: 0.51))
            }

        case "time":
            if let period = entry.extraData["currentPeriod"] {
                Label(period, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        default:
            EmptyView()
        }
    }

    private var rollingIndicator: some View {
        HStack(spacing: 4) {
            if entry.totalFavorites > 1 {
                ForEach(0..<min(entry.totalFavorites, 7), id: \.self) { i in
                    Circle()
                        .fill(i == entry.currentIndex % min(entry.totalFavorites, 7) ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
                if entry.totalFavorites > 7 {
                    Text("+\(entry.totalFavorites - 7)")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Large Widget View
struct LargeFavoritesView: View {
    let entry: FavoritesFortuneEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(entry.icon)
                    .font(.largeTitle)

                VStack(alignment: .leading) {
                    Text(entry.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if entry.totalFavorites > 1 {
                        Text("\(entry.currentIndex + 1)/\(entry.totalFavorites) 즐겨찾기")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Score badge
                if let score = entry.score {
                    VStack {
                        Text(score)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(scoreColor(for: Int(score) ?? 0))
                        Text("점")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 70)
                }
            }

            Divider()

            // Type-specific detailed content
            detailedContentView

            Spacer()

            // Message
            if let message = entry.message {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘의 메시지")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            // Rolling indicator
            rollingIndicator
        }
    }

    @ViewBuilder
    private var detailedContentView: some View {
        switch entry.fortuneType {
        case "daily":
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let luckyColor = entry.extraData["luckyColor"] {
                    InfoCard(icon: "paintpalette", title: "행운의 색", value: luckyColor)
                }
                if let luckyNumber = entry.extraData["luckyNumber"] {
                    InfoCard(icon: "number", title: "행운의 숫자", value: luckyNumber)
                }
                if let percentile = entry.extraData["percentile"] {
                    InfoCard(icon: "chart.bar", title: "상위", value: "\(percentile)%")
                }
            }

        case "investment":
            VStack(alignment: .leading, spacing: 8) {
                if let lottoNumbers = entry.extraData["lottoNumbers"] {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("추천 번호")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lottoNumbers)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                if let sector = entry.extraData["sector"] {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.secondary)
                        Text("추천 섹터: \(sector)")
                            .font(.subheadline)
                    }
                }
            }

        case "biorhythm":
            HStack(spacing: 16) {
                if let physical = entry.extraData["physical"] {
                    BiorhythmBar(title: "신체", value: Int(physical) ?? 50, color: .red)
                }
                if let emotional = entry.extraData["emotional"] {
                    BiorhythmBar(title: "감정", value: Int(emotional) ?? 50, color: .blue)
                }
                if let intellectual = entry.extraData["intellectual"] {
                    BiorhythmBar(title: "지성", value: Int(intellectual) ?? 50, color: .green)
                }
            }

        case "mbti":
            VStack(alignment: .leading, spacing: 8) {
                if let mbtiType = entry.extraData["mbtiType"] {
                    HStack {
                        Text(mbtiType)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Spacer()
                    }
                }
                if let mood = entry.extraData["mood"] {
                    Label("오늘의 기분: \(mood)", systemImage: "face.smiling")
                        .font(.subheadline)
                }
            }

        case "tarot":
            if let cardName = entry.extraData["cardName"] {
                VStack(alignment: .center, spacing: 8) {
                    Text(cardName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.29, green: 0.0, blue: 0.51))
                    if let interpretation = entry.extraData["interpretation"] {
                        Text(interpretation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
            }

        case "moving":
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let direction = entry.extraData["bestDirection"] {
                    InfoCard(icon: "location.north", title: "좋은 방향", value: direction)
                }
                if let date = entry.extraData["bestDate"] {
                    InfoCard(icon: "calendar", title: "좋은 날", value: date)
                }
            }

        default:
            EmptyView()
        }
    }

    private var rollingIndicator: some View {
        HStack {
            Spacer()
            if entry.totalFavorites > 1 {
                ForEach(0..<min(entry.totalFavorites, 10), id: \.self) { i in
                    Circle()
                        .fill(i == entry.currentIndex % min(entry.totalFavorites, 10) ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                if entry.totalFavorites > 10 {
                    Text("+\(entry.totalFavorites - 10)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Helper Views
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BiorhythmBar: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 30, height: 60)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 30, height: CGFloat(value) * 0.6)
            }
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Widget Configuration
struct FavoritesFortuneWidget: Widget {
    let kind: String = "FavoritesFortuneWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoritesFortuneProvider()) { entry in
            if #available(iOS 17.0, *) {
                FavoritesFortuneWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FavoritesFortuneWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("즐겨찾기 운세")
        .description("즐겨찾기한 운세를 1분마다 롤링하여 보여줍니다")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
struct FavoritesFortuneWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FavoritesFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")

            FavoritesFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")

            FavoritesFortuneWidgetView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")

            FavoritesFortuneWidgetView(entry: .empty)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Empty State")
        }
    }
}
