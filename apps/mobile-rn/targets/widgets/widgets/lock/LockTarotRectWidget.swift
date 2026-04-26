//
//  LockTarotRectWidget.swift
//  Ondo Widget Extension
//
//  잠금화면 — accessoryRectangular. 작은 카드 + 이름 + 키워드.
//

import WidgetKit
import SwiftUI

struct LockTarotRectEntry: TimelineEntry {
    let date: Date
    let data: TarotCardData?
}

struct LockTarotRectProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockTarotRectEntry {
        LockTarotRectEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (LockTarotRectEntry) -> Void) {
        completion(LockTarotRectEntry(date: Date(), data: SharedStore.readBundle()?.tarot))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockTarotRectEntry>) -> Void) {
        let entry = LockTarotRectEntry(date: Date(), data: SharedStore.readBundle()?.tarot)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LockTarotRectWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockTarotRectWidget", provider: LockTarotRectProvider()) { entry in
            LockTarotRectView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("ONDO · 오늘의 타로")
        .description("잠금화면에 오늘의 카드.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct LockTarotRectView: View {
    let entry: LockTarotRectEntry

    var body: some View {
        HStack(spacing: 10) {
            LockTarotMiniCard(ko: entry.data?.ko ?? "—")
                .frame(width: 32, height: 48)
            VStack(alignment: .leading, spacing: 1) {
                Text("오늘의 카드")
                    .font(.system(size: 8))
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.55))
                Text(entry.data?.name ?? "—")
                    .font(.custom("ZenSerif", size: 15).weight(.heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(entry.data?.keyword ?? "희망 · 평온 · 회복")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_luna&fortuneType=tarot"))
    }
}

private struct LockTarotMiniCard: View {
    let ko: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.white.opacity(0.25))
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
            VStack(spacing: 0) {
                Text("✦")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                Text(ko)
                    .font(.custom("ZenSerif", size: 10).weight(.heavy))
                    .foregroundColor(.white)
            }
        }
    }
}
