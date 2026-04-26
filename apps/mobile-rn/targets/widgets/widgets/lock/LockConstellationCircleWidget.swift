//
//  LockConstellationCircleWidget.swift
//  Ondo Widget Extension
//
//  잠금화면 — accessoryCircular. 별자리 심볼 + "쌍둥이" + #N 순위.
//

import WidgetKit
import SwiftUI

struct LockConstellationEntry: TimelineEntry {
    let date: Date
    let data: ConstellationData?
}

struct LockConstellationProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockConstellationEntry {
        LockConstellationEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (LockConstellationEntry) -> Void) {
        completion(LockConstellationEntry(date: Date(), data: SharedStore.readBundle()?.constellation))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockConstellationEntry>) -> Void) {
        let entry = LockConstellationEntry(date: Date(), data: SharedStore.readBundle()?.constellation)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LockConstellationCircleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockConstellationCircleWidget",
                            provider: LockConstellationProvider()) { entry in
            LockConstellationCircleView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("별자리 · 오늘의 순위")
        .description("잠금화면에 별자리 심볼과 순위.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct LockConstellationCircleView: View {
    let entry: LockConstellationEntry

    var body: some View {
        VStack(spacing: 1) {
            Text(entry.data?.symbol ?? "✦")
                .font(.custom("ZenSerif", size: 22))
                .foregroundColor(.white)
            Text((entry.data?.sign ?? "—").replacingOccurrences(of: "자리", with: ""))
                .font(.system(size: 8))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.75))
            Text("#\(entry.data?.rank ?? 0)")
                .font(.system(size: 9, weight: .heavy))
                .foregroundColor(.white)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_stella&fortuneType=zodiac"))
    }
}
