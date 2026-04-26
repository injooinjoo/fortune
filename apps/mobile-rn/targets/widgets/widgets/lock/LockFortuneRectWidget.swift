//
//  LockFortuneRectWidget.swift
//  Ondo Widget Extension
//
//  잠금화면 — accessoryRectangular. level + 점수 + 한 줄 요약.
//

import WidgetKit
import SwiftUI

struct LockFortuneRectEntry: TimelineEntry {
    let date: Date
    let data: DailyFortune?
}

struct LockFortuneRectProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockFortuneRectEntry {
        LockFortuneRectEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (LockFortuneRectEntry) -> Void) {
        completion(LockFortuneRectEntry(date: Date(), data: SharedStore.readBundle()?.daily))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockFortuneRectEntry>) -> Void) {
        let entry = LockFortuneRectEntry(date: Date(), data: SharedStore.readBundle()?.daily)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LockFortuneRectWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockFortuneRectWidget", provider: LockFortuneRectProvider()) { entry in
            LockFortuneRectView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("ONDO · 오늘의 운세")
        .description("잠금화면에 운세 level과 점수.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct LockFortuneRectView: View {
    let entry: LockFortuneRectEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("ONDO · 오늘의 운세")
                .font(.system(size: 9))
                .tracking(1)
                .foregroundColor(.white.opacity(0.6))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(entry.data?.level ?? "—")
                    .font(.custom("ZenSerif", size: 20).weight(.heavy))
                    .tracking(0.3)
                    .foregroundColor(.white)
                Text("\(entry.data?.score ?? 0)점")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }

            Text(entry.data?.summary ?? "하루의 흐름을 준비 중이에요.")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily"))
    }
}
