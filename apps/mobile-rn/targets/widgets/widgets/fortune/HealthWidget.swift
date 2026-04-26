//
//  HealthWidget.swift
//  Ondo Widget Extension
//
//  오늘의 건강운 — small. green Ring(44) + "맑음" + 한 줄 요약.
//

import WidgetKit
import SwiftUI

struct HealthEntry: TimelineEntry {
    let date: Date
    let data: HealthFortuneData?
}

struct HealthProvider: TimelineProvider {
    func placeholder(in context: Context) -> HealthEntry {
        HealthEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (HealthEntry) -> Void) {
        completion(HealthEntry(date: Date(), data: SharedStore.readBundle()?.health))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<HealthEntry>) -> Void) {
        let entry = HealthEntry(date: Date(), data: SharedStore.readBundle()?.health)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct HealthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HealthWidget", provider: HealthProvider()) { entry in
            HealthWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 건강운")
        .description("컨디션 맑음·흐림을 한눈에.")
        .supportedFamilies([.systemSmall])
    }
}

struct HealthWidgetView: View {
    let entry: HealthEntry
    private var score: Int { entry.data?.score ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("오늘의 건강운")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Text("ONDO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(OndoPalette.fgMuted)
            }

            HStack(spacing: 10) {
                HealthRing(score: score)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(weatherLabel(score))
                        .font(.custom("ZenSerif", size: 22).weight(.heavy))
                        .foregroundColor(OndoPalette.jade)
                    Text("컨디션 좋은 날")
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fg.opacity(0.7))
                }
            }

            Spacer()

            Text(entry.data?.summary ?? "맑고 가벼운 컨디션")
                .font(.system(size: 12))
                .foregroundColor(OndoPalette.fg)
                .lineLimit(2)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_marco&fortuneType=health"))
    }

    private func weatherLabel(_ s: Int) -> String {
        switch s {
        case 80...: return "맑음"
        case 60..<80: return "양호"
        case 40..<60: return "흐림"
        default: return "주의"
        }
    }
}

private struct HealthRing: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(100, score))) / 100)
                .stroke(OndoPalette.jade, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(OndoPalette.fg)
        }
    }
}
