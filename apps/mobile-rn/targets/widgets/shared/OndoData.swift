//
//  OndoData.swift
//  Ondo Widget Extension
//
//  RN 측 `WidgetDataBundle` (apps/mobile-rn/src/lib/widget-data-sync.ts)
//  JSON 스키마를 Swift Codable 로 미러링. 필드 추가 시 양쪽 동시 수정 필수.
//
//  Sprint W2 — 20 위젯 포팅용 확장: constellation, lucky, weekly, story,
//  unread, recommendation, tarotDraw, health, wealth, dream 추가.
//

import Foundation

// MARK: - W1 baseline models

struct FortuneBreakdown: Codable {
    let career: Int
    let love: Int
    let wealth: Int
    let health: Int
}

struct Lucky: Codable {
    let color: String
    let number: Int
    let direction: String
    let item: String
}

struct DailyFortune: Codable {
    let score: Int
    let level: String
    let summary: String
    let body: String?
    let fortune: FortuneBreakdown
    let lucky: Lucky?
}

struct TarotCardData: Codable {
    let name: String
    let ko: String
    let keyword: String
    let reading: String
    let arcana: String?
}

struct LoveFortune: Codable {
    let score: Int
    let oneLiner: String
    let subtitle: String?
}

// MARK: - W2 extensions

struct ConstellationData: Codable {
    let sign: String       // "쌍둥이자리"
    let symbol: String     // "♊"
    let ko: String         // "Gemini"
    let date: String       // "5.21 — 6.21"
    let rank: Int          // 1-12
    let message: String?
}

struct LuckyColor: Codable {
    let name: String
    let hex: String        // "#5C1F2B"
}

struct LuckyItemData: Codable {
    let color: LuckyColor
    let number: Int
    let direction: String
    let item: String
    let time: String
}

struct WeeklyDay: Codable {
    let d: String          // "월"
    let score: Int
    let hi: Bool
}

struct StoryPreviewData: Codable {
    let name: String       // "해린"
    let subtitle: String   // "출판사 편집자"
    let tint: String       // "#E0A76B" (hex)
    let avatar: String     // "해" or emoji
    let typing: Bool
}

struct UnreadItem: Codable {
    let characterName: String
    let preview: String
    let tint: String       // hex
    let avatar: String
}

struct UnreadData: Codable {
    let total: Int
    let items: [UnreadItem]
}

struct RecommendationData: Codable {
    let name: String
    let subtitle: String
    let hook: String
    let tint: String       // hex
    let avatar: String     // emoji / glyph
}

struct TarotDrawData: Codable {
    let hint: String
    let subhint: String?
    let cards: [TarotCardData] // 3 cards
}

struct HealthFortuneData: Codable {
    let score: Int
    let summary: String
}

struct WealthFortuneData: Codable {
    let luckyNumber: Int
    let summary: String
}

struct DreamData: Codable {
    let message: String
}

// MARK: - Bundle

struct WidgetDataBundle: Codable {
    let daily: DailyFortune?
    let tarot: TarotCardData?
    let love: LoveFortune?
    let constellation: ConstellationData?
    let lucky: LuckyItemData?
    let weekly: [WeeklyDay]?
    let story: StoryPreviewData?
    let unread: UnreadData?
    let recommendation: RecommendationData?
    let tarotDraw: TarotDrawData?
    let health: HealthFortuneData?
    let wealth: WealthFortuneData?
    let dream: DreamData?
    let updatedAt: String
}
