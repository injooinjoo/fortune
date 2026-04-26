//
//  DailyFortuneWidget.swift
//  Ondo Widget Extension
//
//  오늘의 운세 — small(점수 링 + 한자 레벨) / medium(4분류 mini bars).
//  자정 5분 이후 timeline refresh — 하루 단위 갱신.
//

import WidgetKit
import SwiftUI

struct DailyFortuneEntry: TimelineEntry {
    let date: Date
    let data: DailyFortune?
}

struct DailyFortuneProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyFortuneEntry {
        DailyFortuneEntry(date: Date(), data: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyFortuneEntry) -> Void) {
        let bundle = SharedStore.readBundle()
        completion(DailyFortuneEntry(date: Date(), data: bundle?.daily))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyFortuneEntry>) -> Void) {
        let bundle = SharedStore.readBundle()
        let entry = DailyFortuneEntry(date: Date(), data: bundle?.daily)
        let nextRefresh = Self.nextMidnight()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    /// 자정 + 5분 이후 한 번 재조회 — 새로운 하루 운세 기점.
    private static func nextMidnight() -> Date {
        let cal = Calendar.current
        let components = DateComponents(hour: 0, minute: 5)
        return cal.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
    }
}

struct DailyFortuneWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DailyFortuneWidget", provider: DailyFortuneProvider()) { entry in
            DailyFortuneWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 운세")
        .description("하루의 점수와 한 줄 요약을 바로 확인해요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DailyFortuneWidgetView: View {
    let entry: DailyFortuneEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            DailyFortuneSmall(data: entry.data)
        case .systemMedium:
            DailyFortuneMedium(data: entry.data)
        default:
            DailyFortuneSmall(data: entry.data)
        }
    }
}

// MARK: - Small

private struct DailyFortuneSmall: View {
    let data: DailyFortune?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("오늘의 운세")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Circle()
                    .fill(OndoPalette.amber)
                    .frame(width: 6, height: 6)
            }

            HStack(spacing: 10) {
                ScoreRing(score: data?.score ?? 0, color: OndoPalette.violet)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(data?.level ?? "—")
                        .font(.custom("ZenSerif", size: 20))
                        .foregroundColor(OndoPalette.amber)
                    Text(Self.dateLabel())
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fgMuted)
                }
            }

            Spacer()

            Text(data?.summary ?? "오늘의 흐름을 준비 중이에요.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(OndoPalette.fg)
                .lineLimit(2)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily"))
    }

    private static func dateLabel() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M.d EEEE"
        return f.string(from: Date())
    }
}

// MARK: - Medium

private struct DailyFortuneMedium: View {
    let data: DailyFortune?

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("오늘의 운세")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Text(data?.level ?? "—")
                    .font(.custom("ZenSerif", size: 26))
                    .foregroundColor(OndoPalette.amber)
                Text("하늘 · 사주 전문가")
                    .font(.system(size: 10))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Text(data?.summary ?? "오늘의 흐름을 준비 중이에요.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(OndoPalette.fg)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().background(Color.white.opacity(0.08))

            VStack(spacing: 8) {
                ForEach(miniCats(), id: \.key) { cat in
                    MiniBar(label: cat.key, value: cat.value, color: cat.color)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_haneul&fortuneType=daily"))
    }

    private struct MiniCat {
        let key: String
        let value: Int
        let color: Color
    }

    private func miniCats() -> [MiniCat] {
        let b = data?.fortune
        return [
            MiniCat(key: "연애", value: b?.love ?? 0, color: OndoPalette.rose),
            MiniCat(key: "재물", value: b?.wealth ?? 0, color: OndoPalette.amber),
            MiniCat(key: "건강", value: b?.health ?? 0, color: OndoPalette.jade),
            MiniCat(key: "업무", value: b?.career ?? 0, color: OndoPalette.sky),
        ]
    }
}

// MARK: - Reusable subviews

private struct ScoreRing: View {
    let score: Int
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(100, score))) / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(OndoPalette.fg)
        }
    }
}

private struct MiniBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(OndoPalette.fg)
                .frame(width: 22, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 3)
                    Rectangle()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(max(0, min(100, value))) / 100,
                               height: 3)
                }
            }
            .frame(height: 3)
            Text("\(value)")
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(color)
                .frame(width: 20, alignment: .trailing)
        }
    }
}
