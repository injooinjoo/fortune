//
//  UnreadWidget.swift
//  Ondo Widget Extension
//
//  안 읽은 메시지 — medium. total 뱃지 + 최대 3 preview rows.
//

import WidgetKit
import SwiftUI

struct UnreadEntry: TimelineEntry {
    let date: Date
    let data: UnreadData?
}

struct UnreadProvider: TimelineProvider {
    func placeholder(in context: Context) -> UnreadEntry {
        UnreadEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (UnreadEntry) -> Void) {
        completion(UnreadEntry(date: Date(), data: SharedStore.readBundle()?.unread))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<UnreadEntry>) -> Void) {
        let entry = UnreadEntry(date: Date(), data: SharedStore.readBundle()?.unread)
        // unread는 앱 푸시 이벤트에 가까우므로 자정 refresh만 (더 자주 reload는 앱이 syncWidgetData 호출).
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct UnreadWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "UnreadWidget", provider: UnreadProvider()) { entry in
            UnreadWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("안 읽은 메시지")
        .description("캐릭터들의 미열독 메시지를 한눈에.")
        .supportedFamilies([.systemMedium])
    }
}

struct UnreadWidgetView: View {
    let entry: UnreadEntry

    private var total: Int { entry.data?.total ?? 0 }
    private var items: [UnreadItem] {
        Array((entry.data?.items ?? []).prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("안 읽은 메시지")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                HStack(spacing: 5) {
                    Circle()
                        .fill(OndoPalette.violet)
                        .frame(width: 5, height: 5)
                    Text("\(total)")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(OndoPalette.violet)
                }
            }

            VStack(spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, m in
                    HStack(spacing: 8) {
                        AvatarSquare(tint: Color.ondoHex(m.tint), glyph: m.avatar, size: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(m.characterName)
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(OndoPalette.fg)
                                .lineLimit(1)
                            Text(m.preview)
                                .font(.system(size: 10))
                                .foregroundColor(OndoPalette.fg.opacity(0.7))
                                .lineLimit(1)
                        }
                        Spacer()
                        Circle()
                            .fill(OndoPalette.violet)
                            .frame(width: 5, height: 5)
                    }
                }

                if items.isEmpty {
                    Text("새로운 메시지가 없어요.")
                        .font(.system(size: 11))
                        .foregroundColor(OndoPalette.fg.opacity(0.6))
                        .padding(.vertical, 6)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat"))
    }
}
