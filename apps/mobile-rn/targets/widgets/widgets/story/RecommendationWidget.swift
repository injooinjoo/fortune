//
//  RecommendationWidget.swift
//  Ondo Widget Extension
//
//  새로 만날 캐릭터 — medium. tint radial glow + emoji avatar + hook 문구.
//

import WidgetKit
import SwiftUI

struct RecommendationEntry: TimelineEntry {
    let date: Date
    let data: RecommendationData?
}

struct RecommendationProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecommendationEntry {
        RecommendationEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (RecommendationEntry) -> Void) {
        completion(RecommendationEntry(date: Date(), data: SharedStore.readBundle()?.recommendation))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<RecommendationEntry>) -> Void) {
        let entry = RecommendationEntry(date: Date(), data: SharedStore.readBundle()?.recommendation)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct RecommendationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RecommendationWidget", provider: RecommendationProvider()) { entry in
            RecommendationWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("새로 만날 캐릭터")
        .description("오늘 만나면 좋을 친구 한 명.")
        .supportedFamilies([.systemMedium])
    }
}

struct RecommendationWidgetView: View {
    let entry: RecommendationEntry

    private var tint: Color { Color.ondoHex(entry.data?.tint) }
    private var avatar: String { entry.data?.avatar ?? "🌙" }
    private var name: String { entry.data?.name ?? "루나" }
    private var sub: String { entry.data?.subtitle ?? "꿈 해몽가" }
    private var hook: String { entry.data?.hook ?? "새벽 3시 17분,\n당신의 꿈을 기다려요." }

    var body: some View {
        ZStack {
            // radial glow backdrop
            RadialGradient(
                gradient: Gradient(colors: [tint.opacity(0.3), tint.opacity(0)]),
                center: UnitPoint(x: 0.75, y: 0.4),
                startRadius: 0,
                endRadius: 180
            )
            StarFieldLayer(count: 14)

            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.22))
                        .frame(width: 96, height: 96)
                        .blur(radius: 8)
                    Circle()
                        .fill(tint)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                        .frame(width: 78, height: 78)
                    Text(avatar)
                        .font(.system(size: 36))
                }
                .frame(width: 96, height: 96)

                VStack(alignment: .leading, spacing: 3) {
                    Text("새로 만날 캐릭터")
                        .font(.system(size: 9))
                        .tracking(2)
                        .foregroundColor(OndoPalette.fg.opacity(0.6))
                    Text(name)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(OndoPalette.fg)
                    Text(sub)
                        .font(.system(size: 10.5))
                        .foregroundColor(OndoPalette.fg.opacity(0.7))
                    Spacer(minLength: 4)
                    Text(hook)
                        .font(.custom("ZenSerif", size: 12.5))
                        .foregroundColor(OndoPalette.fg)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat"))
    }
}
