//
//  LockScoreCircleWidget.swift
//  Ondo Widget Extension
//
//  잠금화면 — accessoryCircular. 오늘의 운세 점수 ring.
//

import WidgetKit
import SwiftUI

struct LockScoreEntry: TimelineEntry {
    let date: Date
    let score: Int
}

struct LockScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScoreEntry {
        LockScoreEntry(date: Date(), score: 0)
    }
    func getSnapshot(in context: Context, completion: @escaping (LockScoreEntry) -> Void) {
        let s = SharedStore.readBundle()?.daily?.score ?? 0
        completion(LockScoreEntry(date: Date(), score: s))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScoreEntry>) -> Void) {
        let s = SharedStore.readBundle()?.daily?.score ?? 0
        let entry = LockScoreEntry(date: Date(), score: s)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LockScoreCircleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockScoreCircleWidget", provider: LockScoreProvider()) { entry in
            LockScoreCircleView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("오늘의 운세 점수")
        .description("잠금화면에 점수 ring.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct LockScoreCircleView: View {
    let entry: LockScoreEntry

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3.5)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(100, entry.score))) / 100)
                .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(entry.score)")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                Text("운세")
                    .font(.system(size: 7))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(2)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily"))
    }
}
