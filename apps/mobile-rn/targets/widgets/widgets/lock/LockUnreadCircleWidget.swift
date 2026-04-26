//
//  LockUnreadCircleWidget.swift
//  Ondo Widget Extension
//
//  잠금화면 — accessoryCircular. 미열독 메시지 카운트.
//

import WidgetKit
import SwiftUI

struct LockUnreadEntry: TimelineEntry {
    let date: Date
    let total: Int
}

struct LockUnreadProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockUnreadEntry {
        LockUnreadEntry(date: Date(), total: 0)
    }
    func getSnapshot(in context: Context, completion: @escaping (LockUnreadEntry) -> Void) {
        completion(LockUnreadEntry(date: Date(), total: SharedStore.readBundle()?.unread?.total ?? 0))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockUnreadEntry>) -> Void) {
        let entry = LockUnreadEntry(date: Date(), total: SharedStore.readBundle()?.unread?.total ?? 0)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LockUnreadCircleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockUnreadCircleWidget", provider: LockUnreadProvider()) { entry in
            LockUnreadCircleView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Ondo · 안 읽은 메시지")
        .description("잠금화면에 안 읽은 메시지 수.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct LockUnreadCircleView: View {
    let entry: LockUnreadEntry

    var body: some View {
        VStack(spacing: 1) {
            Text("안읽음")
                .font(.system(size: 8))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.6))
            Text("\(entry.total)")
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
            Text("Ondo")
                .font(.system(size: 7, weight: .heavy))
                .foregroundColor(.white.opacity(0.85))
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat"))
    }
}
