import Foundation
import SwiftUI

// MARK: - App Groups Data Source

/// Reads fortune data from App Groups UserDefaults (shared with iPhone app)
final class AppGroupsDataSource {

    // MARK: - Constants

    private let appGroupId = "group.com.beyond.fortune"

    // MARK: - UserDefaults Keys (Must match Flutter widget_data_service.dart)

    private enum Keys {
        // Overall Fortune
        static let overallScore = "overall_score"
        static let overallGrade = "overall_grade"
        static let overallMessage = "overall_message"

        // Biorhythm
        static let bioPhysicalScore = "bio_physical_score"
        static let bioEmotionalScore = "bio_emotional_score"
        static let bioIntellectualScore = "bio_intellectual_score"
        static let bioPhysicalStatus = "bio_physical_status"
        static let bioEmotionalStatus = "bio_emotional_status"
        static let bioIntellectualStatus = "bio_intellectual_status"
        static let bioOverallScore = "bio_overall_score"
        static let bioStatusMessage = "bio_status_message"

        // Lucky Items
        static let luckyColor = "lucky_color"
        static let luckyNumber = "lucky_number"
        static let luckyDirection = "lucky_direction"
        static let luckyTime = "lucky_time"
        static let luckyItem = "lucky_item"

        // Time Slots
        static let timeslotName = "timeslot_name"
        static let timeslotScore = "timeslot_score"
        static let timeslotMessage = "timeslot_message"

        // New Feature Keys (Tarot, Compatibility, Advice)
        static let tarotCardName = "tarot_card_name"
        static let tarotCardNumber = "tarot_card_number"
        static let tarotIsReversed = "tarot_is_reversed"
        static let tarotInterpretation = "tarot_interpretation"
        static let tarotAdvice = "tarot_advice"

        static let compatibilityPartnerName = "compatibility_partner_name"
        static let compatibilityScore = "compatibility_score"
        static let compatibilitySummary = "compatibility_summary"

        static let adviceDo = "advice_do"
        static let adviceDont = "advice_dont"
        static let adviceFocus = "advice_focus"
        static let adviceQuote = "advice_quote"

        // Metadata
        static let validDate = "valid_date"
        static let lastUpdated = "last_updated"
    }

    // MARK: - Shared Defaults

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    // MARK: - Read Methods

    /// Load overall fortune data
    func loadFortuneData() -> FortuneData {
        guard let defaults = sharedDefaults else { return .empty }

        return FortuneData(
            overallScore: defaults.integer(forKey: Keys.overallScore),
            overallGrade: defaults.string(forKey: Keys.overallGrade) ?? "",
            overallMessage: defaults.string(forKey: Keys.overallMessage) ?? "",
            validDate: defaults.string(forKey: Keys.validDate) ?? "",
            lastUpdated: defaults.string(forKey: Keys.lastUpdated) ?? ""
        )
    }

    /// Load biorhythm data
    func loadBiorhythmData() -> BiorhythmData {
        guard let defaults = sharedDefaults else { return .empty }

        var physical = defaults.integer(forKey: Keys.bioPhysicalScore)
        var emotional = defaults.integer(forKey: Keys.bioEmotionalScore)
        var intellectual = defaults.integer(forKey: Keys.bioIntellectualScore)
        var overall = defaults.integer(forKey: Keys.bioOverallScore)

        // Default to 50 if no data
        if physical == 0 { physical = 50 }
        if emotional == 0 { emotional = 50 }
        if intellectual == 0 { intellectual = 50 }
        if overall == 0 { overall = 50 }

        return BiorhythmData(
            physicalScore: physical,
            emotionalScore: emotional,
            intellectualScore: intellectual,
            physicalStatus: defaults.string(forKey: Keys.bioPhysicalStatus) ?? "",
            emotionalStatus: defaults.string(forKey: Keys.bioEmotionalStatus) ?? "",
            intellectualStatus: defaults.string(forKey: Keys.bioIntellectualStatus) ?? "",
            overallScore: overall,
            statusMessage: defaults.string(forKey: Keys.bioStatusMessage) ?? ""
        )
    }

    /// Load lucky items data
    func loadLuckyItemsData() -> LuckyItemsData {
        guard let defaults = sharedDefaults else { return .empty }

        return LuckyItemsData(
            color: defaults.string(forKey: Keys.luckyColor) ?? "",
            number: defaults.string(forKey: Keys.luckyNumber) ?? "",
            direction: defaults.string(forKey: Keys.luckyDirection) ?? "",
            time: defaults.string(forKey: Keys.luckyTime) ?? "",
            item: defaults.string(forKey: Keys.luckyItem) ?? ""
        )
    }

    /// Load time slots data
    func loadTimeSlots() -> [TimeSlotData] {
        guard let defaults = sharedDefaults else { return [] }

        let currentName = defaults.string(forKey: Keys.timeslotName) ?? ""
        let currentScore = defaults.integer(forKey: Keys.timeslotScore)
        let currentMessage = defaults.string(forKey: Keys.timeslotMessage) ?? ""

        return [
            TimeSlotData(
                key: "morning",
                name: "오전",
                icon: "sunrise.fill",
                score: currentName == "오전" ? currentScore : 80,
                message: currentName == "오전" ? currentMessage : "",
                isCurrent: isCurrentTimeSlot("morning")
            ),
            TimeSlotData(
                key: "afternoon",
                name: "오후",
                icon: "sun.max.fill",
                score: currentName == "오후" ? currentScore : 80,
                message: currentName == "오후" ? currentMessage : "",
                isCurrent: isCurrentTimeSlot("afternoon")
            ),
            TimeSlotData(
                key: "evening",
                name: "저녁",
                icon: "moon.fill",
                score: currentName == "저녁" ? currentScore : 80,
                message: currentName == "저녁" ? currentMessage : "",
                isCurrent: isCurrentTimeSlot("evening")
            )
        ]
    }

    /// Load tarot card data
    func loadTarotData() -> TarotCardData? {
        guard let defaults = sharedDefaults else { return nil }
        let cardName = defaults.string(forKey: Keys.tarotCardName) ?? ""
        if cardName.isEmpty { return nil }

        return TarotCardData(
            cardName: cardName,
            cardNumber: defaults.integer(forKey: Keys.tarotCardNumber),
            isReversed: defaults.bool(forKey: Keys.tarotIsReversed),
            interpretation: defaults.string(forKey: Keys.tarotInterpretation) ?? "",
            advice: defaults.string(forKey: Keys.tarotAdvice) ?? "",
            imageUrl: nil
        )
    }

    /// Load compatibility data
    func loadCompatibilityData() -> CompatibilityData? {
        guard let defaults = sharedDefaults else { return nil }
        let partnerName = defaults.string(forKey: Keys.compatibilityPartnerName) ?? ""
        if partnerName.isEmpty { return nil }

        return CompatibilityData(
            partnerName: partnerName,
            compatibilityScore: defaults.integer(forKey: Keys.compatibilityScore),
            summary: defaults.string(forKey: Keys.compatibilitySummary) ?? "",
            strengths: [],
            challenges: []
        )
    }

    /// Load daily advice data
    func loadDailyAdviceData() -> DailyAdviceData? {
        guard let defaults = sharedDefaults else { return nil }
        let doAdvice = defaults.string(forKey: Keys.adviceDo) ?? ""
        if doAdvice.isEmpty { return nil }

        return DailyAdviceData(
            doAdvice: doAdvice,
            dontAdvice: defaults.string(forKey: Keys.adviceDont) ?? "",
            focusArea: defaults.string(forKey: Keys.adviceFocus) ?? "",
            motivationalQuote: defaults.string(forKey: Keys.adviceQuote) ?? ""
        )
    }

    // MARK: - Helpers

    private func isCurrentTimeSlot(_ slot: String) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())

        switch slot {
        case "morning":
            return hour >= 6 && hour < 12
        case "afternoon":
            return hour >= 12 && hour < 18
        case "evening":
            return hour >= 18 || hour < 6
        default:
            return false
        }
    }

    /// Get current time slot
    func getCurrentTimeSlot() -> TimeSlotData? {
        let slots = loadTimeSlots()
        return slots.first { $0.isCurrent }
    }
}
