//
//  WeeklyWidget.swift
//  Ondo Widget Extension
//
//  이번 주의 운세 — medium. 7일 bar chart, 강조일 violet glow.
//

import WidgetKit
import SwiftUI

struct WeeklyEntry: TimelineEntry {
    let date: Date
    let data: [WeeklyDay]?
}

struct WeeklyProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyEntry {
        WeeklyEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (WeeklyEntry) -> Void) {
        completion(WeeklyEntry(date: Date(), data: SharedStore.readBundle()?.weekly))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyEntry>) -> Void) {
        let entry = WeeklyEntry(date: Date(), data: SharedStore.readBundle()?.weekly)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct WeeklyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WeeklyWidget", provider: WeeklyProvider()) { entry in
            WeeklyWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("이번 주의 운세")
        .description("7일의 흐름을 한눈에, 가장 좋은 날을 강조해드려요.")
        .supportedFamilies([.systemMedium])
    }
}

struct WeeklyWidgetView: View {
    let entry: WeeklyEntry

    private var days: [WeeklyDay] {
        entry.data ?? [
            WeeklyDay(d: "월", score: 0, hi: false),
            WeeklyDay(d: "화", score: 0, hi: false),
            WeeklyDay(d: "수", score: 0, hi: false),
            WeeklyDay(d: "목", score: 0, hi: false),
            WeeklyDay(d: "금", score: 0, hi: false),
            WeeklyDay(d: "토", score: 0, hi: false),
            WeeklyDay(d: "일", score: 0, hi: false),
        ]
    }

    private var highlightLabel: String {
        days.first(where: { $0.hi })?.d ?? "이번 주"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("이번 주의 운세")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Text("ONDO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(OndoPalette.fgMuted)
            }

            Spacer(minLength: 12)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, d in
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottom) {
                            // value label hovering above highlight bar
                            if d.hi {
                                Text("\(d.score)")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(OndoPalette.amber)
                                    .offset(y: -barHeight(d.score) - 12)
                            }
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(d.hi ? OndoPalette.violet : Color.white.opacity(0.10))
                                .frame(width: 20, height: max(8, barHeight(d.score)))
                                .shadow(color: d.hi ? OndoPalette.violet.opacity(0.5) : .clear,
                                        radius: d.hi ? 8 : 0)
                        }
                        .frame(height: 72, alignment: .bottom)
                        Text(d.d)
                            .font(.system(size: 10, weight: d.hi ? .heavy : .medium))
                            .foregroundColor(d.hi ? OndoPalette.amber : OndoPalette.fg.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer(minLength: 6)

            HStack(spacing: 0) {
                Text("\(highlightLabel)요일")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(OndoPalette.amber)
                Text("이 가장 좋은 날이에요")
                    .font(.system(size: 11))
                    .foregroundColor(OndoPalette.fg.opacity(0.75))
            }
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily"))
    }

    private func barHeight(_ score: Int) -> CGFloat {
        let s = max(0, min(100, score))
        return CGFloat(s) * 0.62 * 72 / 100
    }
}
