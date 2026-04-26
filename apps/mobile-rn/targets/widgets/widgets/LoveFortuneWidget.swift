//
//  LoveFortuneWidget.swift
//  Ondo Widget Extension
//
//  연애 운 — small only. 핑크 링 + ZenSerif 한 줄 poetry.
//  medium/large는 W2에서 확장.
//

import WidgetKit
import SwiftUI

struct LoveFortuneEntry: TimelineEntry {
    let date: Date
    let data: LoveFortune?
}

struct LoveFortuneProvider: TimelineProvider {
    func placeholder(in context: Context) -> LoveFortuneEntry {
        LoveFortuneEntry(date: Date(), data: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (LoveFortuneEntry) -> Void) {
        let bundle = SharedStore.readBundle()
        completion(LoveFortuneEntry(date: Date(), data: bundle?.love))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LoveFortuneEntry>) -> Void) {
        let bundle = SharedStore.readBundle()
        let entry = LoveFortuneEntry(date: Date(), data: bundle?.love)
        let nextRefresh = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct LoveFortuneWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LoveFortuneWidget", provider: LoveFortuneProvider()) { entry in
            LoveFortuneWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 연애운")
        .description("가볍게 스치는 설렘의 온도.")
        .supportedFamilies([.systemSmall])
    }
}

struct LoveFortuneWidgetView: View {
    let entry: LoveFortuneEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("오늘의 연애운")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Circle()
                    .fill(OndoPalette.rose)
                    .frame(width: 6, height: 6)
            }

            HStack(spacing: 10) {
                LoveScoreRing(score: entry.data?.score ?? 0)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.data?.score ?? 0)")
                        .font(.custom("ZenSerif", size: 22))
                        .foregroundColor(OndoPalette.rose)
                    Text(entry.data?.subtitle ?? "—")
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fgMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(entry.data?.oneLiner ?? "설렘의 온도를 기다리는 중.")
                .font(.custom("ZenSerif", size: 13))
                .foregroundColor(OndoPalette.fg)
                .lineLimit(2)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_rose&fortuneType=love"))
    }
}

// MARK: - Ring

private struct LoveScoreRing: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(100, score))) / 100)
                .stroke(OndoPalette.rose,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("♡")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(OndoPalette.rose)
        }
    }
}
