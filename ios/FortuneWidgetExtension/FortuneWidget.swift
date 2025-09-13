import WidgetKit
import SwiftUI

@main
struct FortuneWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        // Daily Fortune Widget
        FortuneWidget()
        
        // Love Compatibility Widget
        LoveFortuneWidget()
        
        // Lock Screen Widget (iOS 16.1+)
        if #available(iOS 16.1, *) {
            LockScreenFortuneWidget()
        }
    }
}

// MARK: - Daily Fortune Widget
struct FortuneWidget: Widget {
    let kind: String = "FortuneWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneProvider()) { entry in
            DailyFortuneWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 운세")
        .description("오늘의 운세와 행운의 아이템을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Love Fortune Widget
struct LoveFortuneWidget: Widget {
    let kind: String = "LoveFortuneWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LoveFortuneProvider()) { entry in
            LoveFortuneWidgetView(entry: entry)
        }
        .configurationDisplayName("연애운 궁합")
        .description("상대방과의 궁합을 확인하세요")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Lock Screen Widget
@available(iOS 16.1, *)
struct LockScreenFortuneWidget: Widget {
    let kind: String = "LockScreenFortuneWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("운세 점수")
        .description("잠금화면에서 오늘의 운세 점수를 확인하세요")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
