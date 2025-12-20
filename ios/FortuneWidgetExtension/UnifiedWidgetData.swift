import Foundation
import WidgetKit

// MARK: - Unified Widget Data Model
// Matches the SharedWidgetData model from Flutter

struct UnifiedWidgetData: Codable {
    let overall: OverallData
    let categories: [String: CategoryData]
    let timeSlots: [TimeSlotData]
    let lottoNumbers: [Int]
    let updatedAt: Date
    let validDate: String

    // MARK: - Nested Data Types

    struct OverallData: Codable {
        let score: Int
        let grade: String
        let message: String
        let description: String?

        enum CodingKeys: String, CodingKey {
            case score = "o_score"
            case grade = "o_grade"
            case message = "o_msg"
            case description = "o_desc"
        }
    }

    struct CategoryData: Codable {
        let name: String
        let score: Int
        let message: String
        let icon: String

        enum CodingKeys: String, CodingKey {
            case name = "n"
            case score = "s"
            case message = "m"
            case icon = "i"
        }
    }

    struct TimeSlotData: Codable {
        let key: String
        let name: String
        let timeRange: String
        let score: Int
        let message: String
        let icon: String

        enum CodingKeys: String, CodingKey {
            case key = "k"
            case name = "n"
            case timeRange = "r"
            case score = "s"
            case message = "m"
            case icon = "i"
        }
    }

    enum CodingKeys: String, CodingKey {
        case overall
        case categories = "cat"
        case timeSlots = "ts"
        case lottoNumbers = "lotto"
        case updatedAt = "updated"
        case validDate = "date"
    }

    // Custom decoding for nested overall data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode overall from flat structure
        let outerContainer = try decoder.container(keyedBy: OverallData.CodingKeys.self)
        overall = OverallData(
            score: try outerContainer.decode(Int.self, forKey: .score),
            grade: try outerContainer.decode(String.self, forKey: .grade),
            message: try outerContainer.decode(String.self, forKey: .message),
            description: try outerContainer.decodeIfPresent(String.self, forKey: .description)
        )

        categories = try container.decode([String: CategoryData].self, forKey: .categories)
        timeSlots = try container.decode([TimeSlotData].self, forKey: .timeSlots)
        lottoNumbers = try container.decode([Int].self, forKey: .lottoNumbers)

        let dateString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        updatedAt = formatter.date(from: dateString) ?? Date()

        validDate = try container.decode(String.self, forKey: .validDate)
    }

    // MARK: - Convenience Methods

    /// Check if data is valid for today
    var isValidForToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let todayStr = formatter.string(from: Date())
        return validDate == todayStr
    }

    /// Get current time slot based on hour
    var currentTimeSlot: TimeSlotData? {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= 6 && hour < 12 {
            return timeSlots.first { $0.key == "morning" }
        } else if hour >= 12 && hour < 18 {
            return timeSlots.first { $0.key == "afternoon" }
        } else {
            return timeSlots.first { $0.key == "evening" }
        }
    }

    /// Get grade emoji
    var gradeEmoji: String {
        switch overall.grade {
        case "대길": return "🌟"
        case "길": return "✨"
        case "평": return "⭐"
        case "흉": return "🌥️"
        case "대흉": return "🌧️"
        default: return "✨"
        }
    }
}

// MARK: - Unified Widget Data Manager

class UnifiedWidgetDataManager {
    static let shared = UnifiedWidgetDataManager()

    private let appGroupIdentifier = "group.com.beyond.fortune"
    private let widgetDataKey = "flutter.unified_widget_data"
    private let selectedCategoryKey = "flutter.selected_category"

    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    // MARK: - Load Data

    func loadWidgetData() -> UnifiedWidgetData? {
        guard let sharedDefaults = sharedDefaults,
              let jsonString = sharedDefaults.string(forKey: widgetDataKey),
              let jsonData = jsonString.data(using: .utf8) else {
            print("[UnifiedWidget] No widget data found")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(UnifiedWidgetData.self, from: jsonData)
        } catch {
            print("[UnifiedWidget] Failed to decode widget data: \(error)")
            return nil
        }
    }

    /// Load individual widget data from HomeWidget storage
    func loadFromHomeWidget() -> (overall: OverallEntry?, category: CategoryEntry?, timeSlot: TimeSlotEntry?, lotto: LottoEntry?) {
        guard let sharedDefaults = sharedDefaults else {
            return (nil, nil, nil, nil)
        }

        // Overall
        let overallScore = sharedDefaults.integer(forKey: "overall_score")
        let overallGrade = sharedDefaults.string(forKey: "overall_grade") ?? ""
        let overallMessage = sharedDefaults.string(forKey: "overall_message") ?? ""
        let overallDescription = sharedDefaults.string(forKey: "overall_description")
        let overall = OverallEntry(
            date: Date(),
            score: overallScore,
            grade: overallGrade,
            message: overallMessage,
            description: overallDescription,
            isPlaceholder: overallScore == 0
        )

        // Category
        let categoryKey = sharedDefaults.string(forKey: "category_key") ?? ""
        let categoryName = sharedDefaults.string(forKey: "category_name") ?? ""
        let categoryScore = sharedDefaults.integer(forKey: "category_score")
        let categoryMessage = sharedDefaults.string(forKey: "category_message") ?? ""
        let categoryIcon = sharedDefaults.string(forKey: "category_icon") ?? "💫"
        let category = CategoryEntry(
            date: Date(),
            categoryKey: categoryKey,
            name: categoryName,
            score: categoryScore,
            message: categoryMessage,
            icon: categoryIcon,
            isPlaceholder: categoryKey.isEmpty
        )

        // TimeSlot
        let timeSlotName = sharedDefaults.string(forKey: "timeslot_name") ?? ""
        let timeSlotScore = sharedDefaults.integer(forKey: "timeslot_score")
        let timeSlotMessage = sharedDefaults.string(forKey: "timeslot_message") ?? ""
        let timeSlotIcon = sharedDefaults.string(forKey: "timeslot_icon") ?? "🌅"
        let timeSlot = TimeSlotEntry(
            date: Date(),
            name: timeSlotName,
            score: timeSlotScore,
            message: timeSlotMessage,
            icon: timeSlotIcon,
            isPlaceholder: timeSlotName.isEmpty
        )

        // Lotto
        let lottoString = sharedDefaults.string(forKey: "lotto_numbers") ?? ""
        let lottoNumbers = lottoString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        let lotto = LottoEntry(
            date: Date(),
            numbers: lottoNumbers,
            isPlaceholder: lottoNumbers.isEmpty
        )

        return (overall, category, timeSlot, lotto)
    }

    /// Get selected category key
    func getSelectedCategory() -> String {
        return sharedDefaults?.string(forKey: selectedCategoryKey) ?? "love"
    }

    /// Check if data is valid for today
    func isDataValidForToday() -> Bool {
        guard let sharedDefaults = sharedDefaults,
              let validDate = sharedDefaults.string(forKey: "valid_date") else {
            return false
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let todayStr = formatter.string(from: Date())

        return validDate == todayStr
    }
}

// MARK: - Widget Entries

struct OverallEntry: TimelineEntry {
    let date: Date
    let score: Int
    let grade: String
    let message: String
    let description: String?
    let isPlaceholder: Bool

    static var placeholder: OverallEntry {
        OverallEntry(
            date: Date(),
            score: 85,
            grade: "길",
            message: "오늘 하루도 좋은 일이 가득할 거예요",
            description: "긍정적인 에너지로 하루를 시작하세요",
            isPlaceholder: true
        )
    }

    static var empty: OverallEntry {
        OverallEntry(
            date: Date(),
            score: 0,
            grade: "-",
            message: "앱을 열어 운세를 확인하세요",
            description: nil,
            isPlaceholder: false
        )
    }

    var gradeEmoji: String {
        switch grade {
        case "대길": return "🌟"
        case "길": return "✨"
        case "평": return "⭐"
        case "흉": return "🌥️"
        case "대흉": return "🌧️"
        default: return "✨"
        }
    }
}

struct CategoryEntry: TimelineEntry {
    let date: Date
    let categoryKey: String
    let name: String
    let score: Int
    let message: String
    let icon: String
    let isPlaceholder: Bool

    static var placeholder: CategoryEntry {
        CategoryEntry(
            date: Date(),
            categoryKey: "love",
            name: "연애운",
            score: 78,
            message: "새로운 만남에 기대해도 좋아요",
            icon: "💕",
            isPlaceholder: true
        )
    }

    static var empty: CategoryEntry {
        CategoryEntry(
            date: Date(),
            categoryKey: "",
            name: "카테고리",
            score: 0,
            message: "카테고리를 선택하세요",
            icon: "💫",
            isPlaceholder: false
        )
    }
}

struct TimeSlotEntry: TimelineEntry {
    let date: Date
    let name: String
    let score: Int
    let message: String
    let icon: String
    let isPlaceholder: Bool

    static var placeholder: TimeSlotEntry {
        TimeSlotEntry(
            date: Date(),
            name: "오전",
            score: 82,
            message: "활발한 에너지가 넘치는 시간대",
            icon: "🌅",
            isPlaceholder: true
        )
    }

    static var empty: TimeSlotEntry {
        TimeSlotEntry(
            date: Date(),
            name: "-",
            score: 0,
            message: "앱을 열어 운세를 확인하세요",
            icon: "⏰",
            isPlaceholder: false
        )
    }
}

struct LottoEntry: TimelineEntry {
    let date: Date
    let numbers: [Int]
    let isPlaceholder: Bool

    static var placeholder: LottoEntry {
        LottoEntry(
            date: Date(),
            numbers: [7, 14, 21, 28, 35],
            isPlaceholder: true
        )
    }

    static var empty: LottoEntry {
        LottoEntry(
            date: Date(),
            numbers: [],
            isPlaceholder: false
        )
    }

    var displayNumbers: [Int] {
        Array(numbers.prefix(5))
    }
}
