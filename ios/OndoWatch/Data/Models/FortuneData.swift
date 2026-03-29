import Foundation
import SwiftUI

// MARK: - Fortune Data Models

/// Overall fortune data
struct FortuneData: Equatable {
    let overallScore: Int
    let overallGrade: String
    let overallMessage: String
    let validDate: String
    let lastUpdated: String

    var isValid: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let todayStr = formatter.string(from: Date())
        return validDate == todayStr && overallScore > 0
    }

    var gradeEmoji: String {
        switch overallGrade {
        case "대길": return "🌟"
        case "길": return "✨"
        case "평": return "⭐"
        case "흉": return "🌥️"
        case "대흉": return "🌧️"
        default: return "✨"
        }
    }

    static let empty = FortuneData(
        overallScore: 0,
        overallGrade: "",
        overallMessage: "",
        validDate: "",
        lastUpdated: ""
    )
}

/// Biorhythm data
struct BiorhythmData: Equatable {
    let physicalScore: Int
    let emotionalScore: Int
    let intellectualScore: Int
    let physicalStatus: String
    let emotionalStatus: String
    let intellectualStatus: String
    let overallScore: Int
    let statusMessage: String

    static let empty = BiorhythmData(
        physicalScore: 50,
        emotionalScore: 50,
        intellectualScore: 50,
        physicalStatus: "",
        emotionalStatus: "",
        intellectualStatus: "",
        overallScore: 50,
        statusMessage: ""
    )
}

/// Lucky items data
struct LuckyItemsData: Equatable {
    let color: String
    let number: String
    let direction: String
    let time: String
    let item: String

    static let empty = LuckyItemsData(
        color: "",
        number: "",
        direction: "",
        time: "",
        item: ""
    )
}

/// Time slot data
struct TimeSlotData: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let name: String
    let icon: String
    let score: Int
    let message: String
    let isCurrent: Bool

    static func == (lhs: TimeSlotData, rhs: TimeSlotData) -> Bool {
        lhs.key == rhs.key && lhs.score == rhs.score
    }
}

/// Tarot card data (NEW)
struct TarotCardData: Equatable {
    let cardName: String
    let cardNumber: Int
    let isReversed: Bool
    let interpretation: String
    let advice: String
    let imageUrl: String?

    static let empty = TarotCardData(
        cardName: "",
        cardNumber: 0,
        isReversed: false,
        interpretation: "",
        advice: "",
        imageUrl: nil
    )
}

/// Compatibility data (NEW)
struct CompatibilityData: Equatable {
    let partnerName: String
    let compatibilityScore: Int
    let summary: String
    let strengths: [String]
    let challenges: [String]

    static let empty = CompatibilityData(
        partnerName: "",
        compatibilityScore: 0,
        summary: "",
        strengths: [],
        challenges: []
    )
}

/// Daily advice data (NEW)
struct DailyAdviceData: Equatable {
    let doAdvice: String
    let dontAdvice: String
    let focusArea: String
    let motivationalQuote: String

    static let empty = DailyAdviceData(
        doAdvice: "",
        dontAdvice: "",
        focusArea: "",
        motivationalQuote: ""
    )
}

// MARK: - Aggregate State

/// Combined state for all Watch app data
struct WatchFortuneState: Equatable {
    var fortune: FortuneData
    var biorhythm: BiorhythmData
    var luckyItems: LuckyItemsData
    var timeSlots: [TimeSlotData]
    var currentTimeSlot: TimeSlotData?
    var tarotCard: TarotCardData?
    var compatibility: CompatibilityData?
    var dailyAdvice: DailyAdviceData?
    var isLoading: Bool
    var error: String?

    static let initial = WatchFortuneState(
        fortune: .empty,
        biorhythm: .empty,
        luckyItems: .empty,
        timeSlots: [],
        currentTimeSlot: nil,
        tarotCard: nil,
        compatibility: nil,
        dailyAdvice: nil,
        isLoading: false,
        error: nil
    )
}

// MARK: - Fortune Tab

enum FortuneTab: String, CaseIterable, Identifiable {
    case daily
    case biorhythm
    case luckyItems
    case timeSlot
    case tarot
    case compatibility
    case advice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "오늘의 운세"
        case .biorhythm: return "바이오리듬"
        case .luckyItems: return "행운 아이템"
        case .timeSlot: return "시간대 운세"
        case .tarot: return "타로 한 장"
        case .compatibility: return "궁합"
        case .advice: return "오늘의 조언"
        }
    }

    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .biorhythm: return "waveform.path.ecg"
        case .luckyItems: return "star.fill"
        case .timeSlot: return "clock.fill"
        case .tarot: return "rectangle.portrait.on.rectangle.portrait.angled.fill"
        case .compatibility: return "heart.fill"
        case .advice: return "lightbulb.fill"
        }
    }
}
