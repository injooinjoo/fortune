//
//  WealthWidget.swift
//  Ondo Widget Extension
//
//  오늘의 재물운 — small. 중앙에 amber luckyNumber 큰 숫자 + 한 줄 요약.
//

import WidgetKit
import SwiftUI

struct WealthEntry: TimelineEntry {
    let date: Date
    let data: WealthFortuneData?
}

struct WealthProvider: TimelineProvider {
    func placeholder(in context: Context) -> WealthEntry {
        WealthEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (WealthEntry) -> Void) {
        completion(WealthEntry(date: Date(), data: SharedStore.readBundle()?.wealth))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WealthEntry>) -> Void) {
        let entry = WealthEntry(date: Date(), data: SharedStore.readBundle()?.wealth)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct WealthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WealthWidget", provider: WealthProvider()) { entry in
            WealthWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 재물운")
        .description("행운의 숫자 한 자리 — 지갑을 여는 타이밍.")
        .supportedFamilies([.systemSmall])
    }
}

struct WealthWidgetView: View {
    let entry: WealthEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("오늘의 재물운")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Text("ONDO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(OndoPalette.fgMuted)
            }

            Spacer(minLength: 2)

            VStack(spacing: 2) {
                Text("LUCKY NO.")
                    .font(.system(size: 10))
                    .tracking(1)
                    .foregroundColor(OndoPalette.fgMuted)
                Text("\(entry.data?.luckyNumber ?? 0)")
                    .font(.custom("ZenSerif", size: 52).weight(.heavy))
                    .foregroundColor(OndoPalette.amber)
                    .kerning(-1)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 2)

            Text(entry.data?.summary ?? "작은 수입 기운이 움직이는 하루")
                .font(.system(size: 11))
                .foregroundColor(OndoPalette.fg.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(2)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_james_kim&fortuneType=wealth"))
    }
}
