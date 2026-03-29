import Foundation
import SwiftUI

// MARK: - Watch Data Manager
/// App Groups를 통해 iPhone 앱에서 저장한 데이터를 읽어오는 매니저
class WatchDataManager: ObservableObject {
    static let shared = WatchDataManager()

    private let appGroupId = "group.com.beyond.ondo"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    // MARK: - Published Properties

    // Overall Fortune
    @Published var overallScore: Int = 0
    @Published var overallGrade: String = ""
    @Published var overallMessage: String = ""

    // Biorhythm
    @Published var bioPhysicalScore: Int = 50
    @Published var bioEmotionalScore: Int = 50
    @Published var bioIntellectualScore: Int = 50
    @Published var bioPhysicalStatus: String = ""
    @Published var bioEmotionalStatus: String = ""
    @Published var bioIntellectualStatus: String = ""
    @Published var bioOverallScore: Int = 50
    @Published var bioStatusMessage: String = ""

    // Lucky Items
    @Published var luckyColor: String = ""
    @Published var luckyNumber: String = ""
    @Published var luckyDirection: String = ""
    @Published var luckyTime: String = ""
    @Published var luckyItem: String = ""

    // Time Slots
    @Published var timeSlots: [TimeSlotData] = []
    @Published var currentTimeSlotName: String = ""
    @Published var currentTimeSlotScore: Int = 0
    @Published var currentTimeSlotMessage: String = ""

    // Metadata
    @Published var validDate: String = ""
    @Published var lastUpdated: String = ""
    @Published var isDataValid: Bool = false

    private init() {}

    // MARK: - Load All Data

    func loadAllData() {
        loadOverallFortune()
        loadBiorhythm()
        loadLuckyItems()
        loadTimeSlots()
        loadMetadata()
        checkDataValidity()
    }

    // MARK: - Load Methods

    private func loadOverallFortune() {
        guard let defaults = sharedDefaults else { return }

        overallScore = defaults.integer(forKey: "overall_score")
        overallGrade = defaults.string(forKey: "overall_grade") ?? ""
        overallMessage = defaults.string(forKey: "overall_message") ?? ""
    }

    private func loadBiorhythm() {
        guard let defaults = sharedDefaults else { return }

        bioPhysicalScore = defaults.integer(forKey: "bio_physical_score")
        bioEmotionalScore = defaults.integer(forKey: "bio_emotional_score")
        bioIntellectualScore = defaults.integer(forKey: "bio_intellectual_score")
        bioPhysicalStatus = defaults.string(forKey: "bio_physical_status") ?? ""
        bioEmotionalStatus = defaults.string(forKey: "bio_emotional_status") ?? ""
        bioIntellectualStatus = defaults.string(forKey: "bio_intellectual_status") ?? ""
        bioOverallScore = defaults.integer(forKey: "bio_overall_score")
        bioStatusMessage = defaults.string(forKey: "bio_status_message") ?? ""

        // 기본값이 0이면 50으로 설정 (데이터 없음 처리)
        if bioPhysicalScore == 0 { bioPhysicalScore = 50 }
        if bioEmotionalScore == 0 { bioEmotionalScore = 50 }
        if bioIntellectualScore == 0 { bioIntellectualScore = 50 }
    }

    private func loadLuckyItems() {
        guard let defaults = sharedDefaults else { return }

        luckyColor = defaults.string(forKey: "lucky_color") ?? ""
        luckyNumber = defaults.string(forKey: "lucky_number") ?? ""
        luckyDirection = defaults.string(forKey: "lucky_direction") ?? ""
        luckyTime = defaults.string(forKey: "lucky_time") ?? ""
        luckyItem = defaults.string(forKey: "lucky_item") ?? ""
    }

    private func loadTimeSlots() {
        guard let defaults = sharedDefaults else { return }

        // 현재 시간대 데이터
        currentTimeSlotName = defaults.string(forKey: "timeslot_name") ?? ""
        currentTimeSlotScore = defaults.integer(forKey: "timeslot_score")
        currentTimeSlotMessage = defaults.string(forKey: "timeslot_message") ?? ""

        // 시간대 목록 생성
        timeSlots = [
            TimeSlotData(
                key: "morning",
                name: "오전",
                icon: "sunrise.fill",
                score: currentTimeSlotName == "오전" ? currentTimeSlotScore : 80,
                message: currentTimeSlotName == "오전" ? currentTimeSlotMessage : "",
                isCurrent: isCurrentTimeSlot("morning")
            ),
            TimeSlotData(
                key: "afternoon",
                name: "오후",
                icon: "sun.max.fill",
                score: currentTimeSlotName == "오후" ? currentTimeSlotScore : 80,
                message: currentTimeSlotName == "오후" ? currentTimeSlotMessage : "",
                isCurrent: isCurrentTimeSlot("afternoon")
            ),
            TimeSlotData(
                key: "evening",
                name: "저녁",
                icon: "moon.fill",
                score: currentTimeSlotName == "저녁" ? currentTimeSlotScore : 80,
                message: currentTimeSlotName == "저녁" ? currentTimeSlotMessage : "",
                isCurrent: isCurrentTimeSlot("evening")
            )
        ]
    }

    private func loadMetadata() {
        guard let defaults = sharedDefaults else { return }

        validDate = defaults.string(forKey: "valid_date") ?? ""
        lastUpdated = defaults.string(forKey: "last_updated") ?? ""
    }

    private func checkDataValidity() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let todayStr = formatter.string(from: Date())

        isDataValid = (validDate == todayStr) && (overallScore > 0)
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

    /// Get grade emoji
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

    /// Get score color
    func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100:
            return .green
        case 60..<80:
            return .yellow
        case 40..<60:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Time Slot Data Model

struct TimeSlotData: Identifiable {
    let id = UUID()
    let key: String
    let name: String
    let icon: String
    let score: Int
    let message: String
    let isCurrent: Bool
}
