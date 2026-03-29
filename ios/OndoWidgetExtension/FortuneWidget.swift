import WidgetKit
import SwiftUI

@main
struct OndoWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        // New Unified Widgets (4 types based on fortune-daily data)
        OndoOverallWidget()        // Overall score and grade
        OndoCategoryWidget()       // Category-specific fortune (love/money/work/study/health)
        OndoTimeSlotWidget()       // Time-based fortune (morning/afternoon/evening)
        OndoLottoWidget()          // Lucky numbers (5 numbers)

        // Legacy widgets (kept for backward compatibility)
        OndoWidget()               // Daily Fortune Widget
        OndoLoveWidget()           // Love Compatibility Widget

        // Lock Screen Widget (iOS 16.1+)
        if #available(iOS 16.1, *) {
            OndoLockScreenWidget()
        }

        // Note: OndoFavoritesWidget removed - replaced by new unified widgets
    }
}

// MARK: - Daily Fortune Widget
struct OndoWidget: Widget {
    let kind: String = "OndoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneProvider()) { entry in
            if #available(iOS 17.0, *) {
                DailyFortuneWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DailyFortuneWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("오늘의 운세")
        .description("오늘의 운세와 행운의 아이템을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Love Fortune Widget
struct OndoLoveWidget: Widget {
    let kind: String = "OndoLoveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LoveFortuneProvider()) { entry in
            if #available(iOS 17.0, *) {
                LoveFortuneWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LoveFortuneWidgetView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("연애운 궁합")
        .description("상대방과의 궁합을 확인하세요")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Lock Screen Widget
@available(iOS 16.1, *)
struct OndoLockScreenWidget: Widget {
    let kind: String = "OndoLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneProvider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockScreenWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("운세 점수")
        .description("잠금화면에서 오늘의 운세 점수를 확인하세요")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
