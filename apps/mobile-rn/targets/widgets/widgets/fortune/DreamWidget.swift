//
//  DreamWidget.swift
//  Ondo Widget Extension
//
//  새벽의 속삭임 — small. StarField + lavender aura 달 이모지 + ZenSerif italic.
//  dream 필드 우선, 없으면 recommendation.hook fallback.
//

import WidgetKit
import SwiftUI

struct DreamEntry: TimelineEntry {
    let date: Date
    let dream: DreamData?
    let recommendation: RecommendationData?
}

struct DreamProvider: TimelineProvider {
    func placeholder(in context: Context) -> DreamEntry {
        DreamEntry(date: Date(), dream: nil, recommendation: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (DreamEntry) -> Void) {
        let b = SharedStore.readBundle()
        completion(DreamEntry(date: Date(), dream: b?.dream, recommendation: b?.recommendation))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DreamEntry>) -> Void) {
        let b = SharedStore.readBundle()
        let entry = DreamEntry(date: Date(), dream: b?.dream, recommendation: b?.recommendation)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct DreamWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DreamWidget", provider: DreamProvider()) { entry in
            DreamWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("새벽의 속삭임")
        .description("조용한 밤, 달의 메시지.")
        .supportedFamilies([.systemSmall])
    }
}

struct DreamWidgetView: View {
    let entry: DreamEntry

    private var message: String {
        entry.dream?.message
            ?? entry.recommendation?.hook
            ?? "새벽 3시 17분,\n당신의 꿈을 기다려요."
    }

    private var avatar: String {
        entry.recommendation?.avatar ?? "🌙"
    }

    private static let lavender = Color(red: 0xB8 / 255, green: 0xB0 / 255, blue: 0xFF / 255)

    var body: some View {
        ZStack {
            StarFieldLayer(count: 14)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("새벽의 속삭임")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Self.lavender.opacity(0.7))
                    Spacer()
                    Circle()
                        .fill(Self.lavender.opacity(0.55))
                        .frame(width: 6, height: 6)
                }

                Spacer()

                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Self.lavender.opacity(0.18))
                            .frame(width: 66, height: 66)
                            .blur(radius: 6)
                        Circle()
                            .fill(Self.lavender.opacity(0.12))
                            .frame(width: 56, height: 56)
                        Text(avatar)
                            .font(.system(size: 34))
                    }
                    Spacer()
                }

                Spacer()

                Text(message)
                    .font(.custom("ZenSerif", size: 11))
                    .italic()
                    .foregroundColor(OndoPalette.fg)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .lineLimit(3)
            }
            .padding(14)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_luna&fortuneType=dream"))
    }
}
