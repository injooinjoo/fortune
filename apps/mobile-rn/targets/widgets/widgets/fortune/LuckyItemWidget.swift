//
//  LuckyItemWidget.swift
//  Ondo Widget Extension
//
//  오늘의 행운 — small. 2×2 grid: 색/수/방위/시간.
//

import WidgetKit
import SwiftUI

struct LuckyItemEntry: TimelineEntry {
    let date: Date
    let data: LuckyItemData?
}

struct LuckyItemProvider: TimelineProvider {
    func placeholder(in context: Context) -> LuckyItemEntry {
        LuckyItemEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (LuckyItemEntry) -> Void) {
        completion(LuckyItemEntry(date: Date(), data: SharedStore.readBundle()?.lucky))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LuckyItemEntry>) -> Void) {
        let entry = LuckyItemEntry(date: Date(), data: SharedStore.readBundle()?.lucky)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LuckyItemWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LuckyItemWidget", provider: LuckyItemProvider()) { entry in
            LuckyItemWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 행운")
        .description("색·수·방위·시간 — 하루의 작은 부적.")
        .supportedFamilies([.systemSmall])
    }
}

struct LuckyItemWidgetView: View {
    let entry: LuckyItemEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("오늘의 행운")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Circle()
                    .fill(OndoPalette.amber)
                    .frame(width: 6, height: 6)
            }

            let color = entry.data?.color
            let hex = color?.hex ?? "#E0A76B"
            let colorName = color?.name ?? "—"
            let number = entry.data?.number ?? 0
            let direction = entry.data?.direction ?? "—"
            let time = entry.data?.time ?? "—"

            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    LuckyCell(label: "색") {
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(Color.ondoHex(hex))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                )
                                .frame(width: 10, height: 10)
                            Text(colorName)
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(OndoPalette.fg)
                                .lineLimit(1)
                        }
                    }
                    LuckyCell(label: "수") {
                        Text("\(number)")
                            .font(.custom("ZenSerif", size: 18).weight(.heavy))
                            .foregroundColor(OndoPalette.amber)
                    }
                }
                HStack(spacing: 4) {
                    LuckyCell(label: "방위") {
                        Text(direction)
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(OndoPalette.fg)
                            .lineLimit(1)
                    }
                    LuckyCell(label: "시간") {
                        Text(time)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(OndoPalette.fg)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_lucky&fortuneType=lucky-items"))
    }
}

private struct LuckyCell<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(OndoPalette.fgMuted)
            content()
        }
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}
