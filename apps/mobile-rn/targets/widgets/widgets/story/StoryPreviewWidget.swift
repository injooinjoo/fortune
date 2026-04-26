//
//  StoryPreviewWidget.swift
//  Ondo Widget Extension
//
//  일반 채팅 — small. 캐릭터 아바타 + typing bubble.
//

import WidgetKit
import SwiftUI

struct StoryPreviewEntry: TimelineEntry {
    let date: Date
    let data: StoryPreviewData?
}

struct StoryPreviewProvider: TimelineProvider {
    func placeholder(in context: Context) -> StoryPreviewEntry {
        StoryPreviewEntry(date: Date(), data: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (StoryPreviewEntry) -> Void) {
        completion(StoryPreviewEntry(date: Date(), data: SharedStore.readBundle()?.story))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<StoryPreviewEntry>) -> Void) {
        let entry = StoryPreviewEntry(date: Date(), data: SharedStore.readBundle()?.story)
        let next = Calendar.current
            .nextDate(after: Date(),
                      matching: DateComponents(hour: 0, minute: 5),
                      matchingPolicy: .nextTime)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct StoryPreviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StoryPreviewWidget", provider: StoryPreviewProvider()) { entry in
            StoryPreviewWidgetView(entry: entry)
                .containerBackground(OndoPalette.bg, for: .widget)
        }
        .configurationDisplayName("일반 채팅")
        .description("캐릭터가 당신을 기다리는 중.")
        .supportedFamilies([.systemSmall])
    }
}

struct StoryPreviewWidgetView: View {
    let entry: StoryPreviewEntry

    private var tint: Color { Color.ondoHex(entry.data?.tint) }
    private var glyph: String { entry.data?.avatar ?? "해" }
    private var name: String { entry.data?.name ?? "—" }
    private var sub: String { entry.data?.subtitle ?? "" }
    private var typing: Bool { entry.data?.typing ?? true }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("일반 채팅")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(OndoPalette.fgMuted)
                Spacer()
                Text("ONDO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(OndoPalette.fgMuted)
            }

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.2))
                        .frame(width: 44, height: 44)
                    AvatarSquare(tint: tint, glyph: glyph, size: 36)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(OndoPalette.fg)
                        .lineLimit(1)
                    Text(sub)
                        .font(.system(size: 10))
                        .foregroundColor(OndoPalette.fg.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
            }

            Spacer()

            HStack(spacing: 6) {
                if typing {
                    TypingDotsView()
                }
                Text(typing ? "입력 중…" : "메시지를 열어보세요")
                    .font(.system(size: 10))
                    .foregroundColor(OndoPalette.fg.opacity(0.7))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .padding(14)
        .widgetURL(URL(string: "com.beyond.fortune://widget?screen=chat"))
    }
}

// MARK: - Primitives

struct AvatarSquare: View {
    let tint: Color
    let glyph: String
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(tint.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
            Text(glyph)
                .font(.system(size: size * 0.5, weight: .heavy))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

struct TypingDotsView: View {
    var body: some View {
        HStack(spacing: 3) {
            Circle().fill(OndoPalette.fg.opacity(0.45)).frame(width: 3.5, height: 3.5)
            Circle().fill(OndoPalette.fg.opacity(0.7)).frame(width: 3.5, height: 3.5)
            Circle().fill(OndoPalette.fg.opacity(0.45)).frame(width: 3.5, height: 3.5)
        }
    }
}
