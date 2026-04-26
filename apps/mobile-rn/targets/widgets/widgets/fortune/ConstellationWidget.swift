//
//  ConstellationWidget.swift
//  Ondo Widget Extension
//
//  별자리 운세 — small(심볼+순위) / medium(심볼+메시지).
//  starSurface 배경 위 sky tint glow + 별자리 심볼 + 순위(#N) + 한 줄 메시지.
//

import WidgetKit
import SwiftUI

struct ConstellationEntry: TimelineEntry {
    let date: Date
    let data: ConstellationData?
}

struct ConstellationProvider: TimelineProvider {
    func placeholder(in context: Context) -> ConstellationEntry {
        ConstellationEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (ConstellationEntry) -> Void) {
        completion(ConstellationEntry(date: Date(), data: SharedStore.readBundle()?.constellation))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ConstellationEntry>) -> Void) {
        let entry = ConstellationEntry(date: Date(), data: SharedStore.readBundle()?.constellation)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct ConstellationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ConstellationWidget", provider: ConstellationProvider()) { entry in
            ConstellationWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("별자리 운세")
        .description("별이 속삭이는 오늘의 순위와 메시지.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ConstellationWidgetView: View {
    let entry: ConstellationEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            ConstellationMedium(data: entry.data)
        default:
            ConstellationSmall(data: entry.data)
        }
    }
}

// MARK: - Small

private struct ConstellationSmall: View {
    let data: ConstellationData?

    var body: some View {
        ZStack {
            StarFieldLayer(count: 12)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("별자리 운세")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(OndoPalette.sky.opacity(0.65))
                    Spacer()
                    Circle()
                        .fill(OndoPalette.sky.opacity(0.55))
                        .frame(width: 6, height: 6)
                }

                HStack(alignment: .center, spacing: 8) {
                    Text(data?.symbol ?? "✦")
                        .font(.custom("ZenSerif", size: 34))
                        .foregroundColor(OndoPalette.sky)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(data?.sign ?? "—")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(OndoPalette.fg)
                            .lineLimit(1)
                        Text(data?.date ?? "")
                            .font(.system(size: 9.5))
                            .foregroundColor(OndoPalette.fgMuted)
                    }
                }

                Spacer()

                HStack {
                    Text("오늘 순위")
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fg.opacity(0.6))
                    Spacer()
                    Text("#\(data?.rank ?? 0)")
                        .font(.custom("ZenSerif", size: 14).weight(.heavy))
                        .foregroundColor(OndoPalette.amber)
                }
            }
            .padding(14)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_stella&fortuneType=zodiac"))
    }
}

// MARK: - Medium

private struct ConstellationMedium: View {
    let data: ConstellationData?

    var body: some View {
        ZStack {
            StarFieldLayer(count: 18)
            HStack(alignment: .center, spacing: 14) {
                VStack(spacing: 4) {
                    Text(data?.symbol ?? "✦")
                        .font(.custom("ZenSerif", size: 56))
                        .foregroundColor(OndoPalette.sky)
                    Text("#\(data?.rank ?? 0)")
                        .font(.custom("ZenSerif", size: 14).weight(.heavy))
                        .foregroundColor(OndoPalette.amber)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("별자리 운세")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(OndoPalette.sky.opacity(0.65))
                    Text(data?.sign ?? "—")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(OndoPalette.fg)
                    Text(data?.date ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fgMuted)
                    Spacer(minLength: 2)
                    Text(data?.message ?? "별이 당신의 하루를 기다리는 중.")
                        .font(.custom("ZenSerif", size: 12))
                        .foregroundColor(OndoPalette.fg.opacity(0.85))
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_stella&fortuneType=zodiac"))
    }
}

// MARK: - StarField

struct StarFieldLayer: View {
    let count: Int

    var body: some View {
        GeometryReader { geo in
            ZStack {
                OndoPalette.bg
                ForEach(0..<count, id: \.self) { i in
                    let seed = Double(i * 13 + 7)
                    let x = (sin(seed) * 0.5 + 0.5) * Double(geo.size.width)
                    let y = (cos(seed * 1.3) * 0.5 + 0.5) * Double(geo.size.height)
                    let size = 1.0 + (sin(seed * 2.7) + 1) * 1.2
                    Circle()
                        .fill(Color.white.opacity(0.28 + (cos(seed * 0.7) + 1) * 0.12))
                        .frame(width: size, height: size)
                        .position(x: x, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
