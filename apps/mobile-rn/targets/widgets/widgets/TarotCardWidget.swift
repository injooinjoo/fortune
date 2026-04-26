//
//  TarotCardWidget.swift
//  Ondo Widget Extension
//
//  오늘의 타로 — small(카드 이미지 + 이름) / medium(카드 + 키워드 + 리딩 한 줄).
//  위젯은 탭 인터랙션만 가능하므로 "카드를 뽑는" UX는 앱으로 deep link.
//

import WidgetKit
import SwiftUI

struct TarotCardEntry: TimelineEntry {
    let date: Date
    let data: TarotCardData?
}

struct TarotCardProvider: TimelineProvider {
    func placeholder(in context: Context) -> TarotCardEntry {
        TarotCardEntry(date: Date(), data: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TarotCardEntry) -> Void) {
        let bundle = SharedStore.readBundle()
        completion(TarotCardEntry(date: Date(), data: bundle?.tarot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TarotCardEntry>) -> Void) {
        let bundle = SharedStore.readBundle()
        let entry = TarotCardEntry(date: Date(), data: bundle?.tarot)
        let nextRefresh = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct TarotCardWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TarotCardWidget", provider: TarotCardProvider()) { entry in
            TarotCardWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("오늘의 타로")
        .description("한 장의 카드로 하루를 여는 시간.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TarotCardWidgetView: View {
    let entry: TarotCardEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            TarotCardSmall(data: entry.data)
        case .systemMedium:
            TarotCardMedium(data: entry.data)
        default:
            TarotCardSmall(data: entry.data)
        }
    }
}

// MARK: - Small

private struct TarotCardSmall: View {
    let data: TarotCardData?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("오늘의 타로")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Circle()
                    .fill(OndoPalette.amber)
                    .frame(width: 6, height: 6)
            }

            Spacer()

            HStack(spacing: 10) {
                TarotCardBack()
                    .frame(width: 44, height: 64)
                VStack(alignment: .leading, spacing: 2) {
                    Text(data?.ko ?? "—")
                        .font(.custom("ZenSerif", size: 18))
                        .foregroundColor(OndoPalette.amber)
                    Text(data?.name ?? "Tarot")
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fgMuted)
                }
            }

            Spacer()

            Text(data?.keyword ?? "희망 · 평온 · 회복")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(OndoPalette.fg)
                .lineLimit(1)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_luna&fortuneType=tarot"))
    }
}

// MARK: - Medium

private struct TarotCardMedium: View {
    let data: TarotCardData?

    var body: some View {
        HStack(spacing: 14) {
            TarotCardBack()
                .frame(width: 64, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                Text("오늘의 타로")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Text(data?.ko ?? "—")
                    .font(.custom("ZenSerif", size: 24))
                    .foregroundColor(OndoPalette.amber)
                Text(data?.arcana ?? "Tarot")
                    .font(.system(size: 10))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer(minLength: 4)
                Text(data?.reading ?? "오늘 당신을 위한 카드 한 장.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(OndoPalette.fg)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat&characterId=fortune_luna&fortuneType=tarot"))
    }
}

// MARK: - Card back visual

private struct TarotCardBack: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [OndoPalette.wine, OndoPalette.violet.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(OndoPalette.amber.opacity(0.6), lineWidth: 1)
            VStack {
                Text("✦")
                    .font(.system(size: 18))
                    .foregroundColor(OndoPalette.amber)
            }
        }
    }
}
