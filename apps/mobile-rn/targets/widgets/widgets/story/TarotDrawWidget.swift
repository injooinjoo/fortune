//
//  TarotDrawWidget.swift
//  Ondo Widget Extension
//
//  타로 한 장 뽑기 — large. 3-card fan (static, tap to open app).
//  위젯 단위 인터랙션은 iOS 17+ AppIntent 필요 → W2에서는 static 렌더.
//

import WidgetKit
import SwiftUI

struct TarotDrawEntry: TimelineEntry {
    let date: Date
    let data: TarotDrawData?
}

struct TarotDrawProvider: TimelineProvider {
    func placeholder(in context: Context) -> TarotDrawEntry {
        TarotDrawEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (TarotDrawEntry) -> Void) {
        completion(TarotDrawEntry(date: Date(), data: SharedStore.readBundle()?.tarotDraw))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TarotDrawEntry>) -> Void) {
        let entry = TarotDrawEntry(date: Date(), data: SharedStore.readBundle()?.tarotDraw)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct TarotDrawWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TarotDrawWidget", provider: TarotDrawProvider()) { entry in
            TarotDrawWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("무현 · 타로 한 장 뽑기")
        .description("3장의 카드에서 오늘의 한 장을 선택.")
        .supportedFamilies([.systemLarge])
    }
}

struct TarotDrawWidgetView: View {
    let entry: TarotDrawEntry

    private var hint: String { entry.data?.hint ?? "오늘의 카드 한 장" }
    private var subhint: String { entry.data?.subhint ?? "손끝으로 덱을 덮어보세요" }
    private var cards: [TarotCardData] {
        entry.data?.cards ?? [
            TarotCardData(name: "The Star", ko: "별", keyword: "희망", reading: "", arcana: nil),
            TarotCardData(name: "The Moon", ko: "달", keyword: "직관", reading: "", arcana: nil),
            TarotCardData(name: "The Sun", ko: "태양", keyword: "생명력", reading: "", arcana: nil),
        ]
    }

    var body: some View {
        ZStack {
            StarFieldLayer(count: 22)
            RadialGradient(
                gradient: Gradient(colors: [OndoPalette.violet.opacity(0.35), OndoPalette.violet.opacity(0)]),
                center: .center,
                startRadius: 0,
                endRadius: 220
            )
            VStack(spacing: 12) {
                HStack {
                    Text("무현 · 타로 한 장 뽑기")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(OndoPalette.fgMuted)
                    Spacer()
                    Text("ONDO")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(OndoPalette.fgMuted)
                }

                VStack(spacing: 4) {
                    Text(hint)
                        .font(.custom("ZenSerif", size: 22).weight(.heavy))
                        .foregroundColor(OndoPalette.amber)
                        .tracking(0.3)
                    Text(subhint)
                        .font(.system(size: 11))
                        .foregroundColor(OndoPalette.fg.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 4)

                // 3-card fan
                HStack(spacing: 10) {
                    ForEach(Array(cards.prefix(3).enumerated()), id: \.offset) { i, _ in
                        let rot: Double = (i == 0) ? -8 : (i == 2 ? 8 : 0)
                        TarotCardBackLarge()
                            .frame(width: 74, height: 118)
                            .rotationEffect(.degrees(rot))
                    }
                }

                Spacer(minLength: 4)

                Text("카드를 탭하세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0xB7 / 255, green: 0xAE / 255, blue: 0xF0 / 255))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(OndoPalette.violet.opacity(0.15))
                            .overlay(
                                Capsule().stroke(OndoPalette.violet.opacity(0.3), lineWidth: 0.5)
                            )
                    )
            }
            .padding(16)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_luna&fortuneType=tarot"))
    }
}

// MARK: - Card visual

private struct TarotCardBackLarge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OndoPalette.wine, OndoPalette.violet.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(OndoPalette.amber.opacity(0.6), lineWidth: 1)
            Text("✦")
                .font(.system(size: 22))
                .foregroundColor(OndoPalette.amber)
        }
    }
}
