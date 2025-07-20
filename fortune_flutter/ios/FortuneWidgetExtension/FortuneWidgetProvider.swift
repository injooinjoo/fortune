import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct FortuneEntry: TimelineEntry {
    let date: Date
    let fortuneScore: Int
    let fortuneMessage: String
    let luckyColor: String
    let luckyNumber: Int
    let detailedFortune: String?
    let isPlaceholder: Bool
    
    static var placeholder: FortuneEntry {
        FortuneEntry(
            date: Date(),
            fortuneScore: 85,
            fortuneMessage: "오늘은 좋은 일이 생길 예정입니다",
            luckyColor: "파란색",
            luckyNumber: 7,
            detailedFortune: nil,
            isPlaceholder: true
        )
    }
    
    static var empty: FortuneEntry {
        FortuneEntry(
            date: Date(),
            fortuneScore: 0,
            fortuneMessage: "운세를 확인하려면 앱을 열어주세요",
            luckyColor: "미정",
            luckyNumber: 0,
            detailedFortune: nil,
            isPlaceholder: false
        )
    }
}

// MARK: - Daily Fortune Provider
struct FortuneProvider: TimelineProvider {
    func placeholder(in context: Context) -> FortuneEntry {
        FortuneEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FortuneEntry) -> ()) {
        let entry = loadFortuneData() ?? FortuneEntry.placeholder
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FortuneEntry>) -> ()) {
        var entries: [FortuneEntry] = []
        
        // Load current fortune data
        let currentEntry = loadFortuneData() ?? FortuneEntry.empty
        entries.append(currentEntry)
        
        // Create timeline that updates every hour
        let currentDate = Date()
        for hourOffset in 1 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            // Keep the same fortune data but update the date
            let entry = FortuneEntry(
                date: entryDate,
                fortuneScore: currentEntry.fortuneScore,
                fortuneMessage: currentEntry.fortuneMessage,
                luckyColor: currentEntry.luckyColor,
                luckyNumber: currentEntry.luckyNumber,
                detailedFortune: currentEntry.detailedFortune,
                isPlaceholder: false
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadFortuneData() -> FortuneEntry? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.fortune.fortune"),
              let data = sharedDefaults.data(forKey: "widget_fortune_daily"),
              let fortuneData = try? JSONDecoder().decode(FortuneWidgetData.self, from: data) else {
            return nil
        }
        
        return FortuneEntry(
            date: Date(),
            fortuneScore: fortuneData.score,
            fortuneMessage: fortuneData.message,
            luckyColor: fortuneData.luckyColor,
            luckyNumber: fortuneData.luckyNumber,
            detailedFortune: fortuneData.detailedFortune,
            isPlaceholder: false
        )
    }
}

// MARK: - Love Fortune Entry
struct LoveFortuneEntry: TimelineEntry {
    let date: Date
    let compatibilityScore: Int
    let partnerName: String
    let message: String
    let advice: String?
    let isPlaceholder: Bool
    
    static var placeholder: LoveFortuneEntry {
        LoveFortuneEntry(
            date: Date(),
            compatibilityScore: 75,
            partnerName: "상대방",
            message: "서로를 이해하려는 노력이 필요합니다",
            advice: nil,
            isPlaceholder: true
        )
    }
}

// MARK: - Love Fortune Provider
struct LoveFortuneProvider: TimelineProvider {
    func placeholder(in context: Context) -> LoveFortuneEntry {
        LoveFortuneEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LoveFortuneEntry) -> ()) {
        completion(LoveFortuneEntry.placeholder)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LoveFortuneEntry>) -> ()) {
        let entry = loadLoveFortuneData() ?? LoveFortuneEntry.placeholder
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
    
    private func loadLoveFortuneData() -> LoveFortuneEntry? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.fortune.fortune"),
              let data = sharedDefaults.data(forKey: "widget_fortune_love"),
              let loveData = try? JSONDecoder().decode(LoveFortuneWidgetData.self, from: data) else {
            return nil
        }
        
        return LoveFortuneEntry(
            date: Date(),
            compatibilityScore: loveData.compatibilityScore,
            partnerName: loveData.partnerName,
            message: loveData.message,
            advice: loveData.advice,
            isPlaceholder: false
        )
    }
}

// MARK: - Widget Data Models
struct FortuneWidgetData: Codable {
    let score: Int
    let message: String
    let luckyColor: String
    let luckyNumber: Int
    let detailedFortune: String?
    let lastUpdated: Date
}

struct LoveFortuneWidgetData: Codable {
    let compatibilityScore: Int
    let partnerName: String
    let message: String
    let advice: String?
    let lastUpdated: Date
}