# iOS Native Features Implementation Guide

## 🍎 Overview

이 문서는 Fortune 앱의 iOS 네이티브 기능 구현을 위한 상세 가이드입니다.

## 📦 Required Dependencies

### Pubspec.yaml
```yaml
dependencies:
  # 기존 의존성...
  
  # iOS Native Features
  live_activities: ^1.8.3
  home_widget: ^0.3.0
  app_intents: ^1.0.0
  flutter_widgetkit: ^0.1.0
  
dev_dependencies:
  # Widget Extension 개발용
  flutter_launcher_icons: ^0.13.1
```

### iOS 프로젝트 설정
```xml
<!-- Info.plist -->
<key>NSUserActivityTypes</key>
<array>
    <string>com.fortune.fortune.viewFortune</string>
    <string>com.fortune.fortune.drawTarot</string>
</array>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 1️⃣ Dynamic Island & Live Activities

### Step 1: Live Activity 정의
```swift
// FortuneActivityAttributes.swift
import ActivityKit
import WidgetKit
import SwiftUI

struct FortuneActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var fortuneScore: Int
        var message: String
        var luckyColor: String
        var timeRemaining: String?
    }
    
    var userName: String
    var fortuneType: String
}
```

### Step 2: Live Activity Widget 구현
```swift
// FortuneLiveActivity.swift
struct FortuneLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FortuneActivityAttributes.self) { context in
            // Lock Screen UI
            VStack {
                HStack {
                    Image("fortune_icon")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(context.attributes.fortuneType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.message)
                            .font(.headline)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    FortuneScoreView(score: context.state.fortuneScore)
                }
                .padding()
            }
            .activityBackgroundTint(Color(hex: context.state.luckyColor))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        FortuneCardView(
                            score: context.state.fortuneScore,
                            message: context.state.message,
                            color: context.state.luckyColor
                        )
                    }
                }
                
                // Compact View
                DynamicIslandExpandedRegion(.leading) {
                    Image("fortune_icon")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.fortuneScore)%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                // Minimal View
                DynamicIslandExpandedRegion(.minimal) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}
```

### Step 3: Flutter 연동
```dart
// live_activity_service.dart
import 'package:live_activities/live_activities.dart';

class LiveActivityService {
  final _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;
  
  Future<void> startFortuneActivity({
    required int fortuneScore,
    required String message,
    required String luckyColor,
    required String userName,
    required String fortuneType,
  }) async {
    final activityModel = LiveActivityModel(
      userName: userName,
      fortuneType: fortuneType,
    );
    
    _currentActivityId = await _liveActivitiesPlugin.createActivity(
      activityModel.toMap(),
    );
    
    // Update with fortune data
    await updateFortuneActivity(
      fortuneScore: fortuneScore,
      message: message,
      luckyColor: luckyColor,
    );
  }
  
  Future<void> updateFortuneActivity({
    required int fortuneScore,
    required String message,
    required String luckyColor,
  }) async {
    if (_currentActivityId == null) return;
    
    await _liveActivitiesPlugin.updateActivity(
      _currentActivityId!,
      {
        'fortuneScore': fortuneScore,
        'message': message,
        'luckyColor': luckyColor,
      },
    );
  }
}
```

## 2️⃣ Lock Screen Widgets

### Widget Extension 생성
```swift
// FortuneWidget.swift
import WidgetKit
import SwiftUI

struct FortuneEntry: TimelineEntry {
    let date: Date
    let fortuneScore: Int
    let message: String
    let luckyColor: Color
    let luckyNumber: Int
}

struct FortuneWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FortuneEntry {
        FortuneEntry(
            date: Date(),
            fortuneScore: 75,
            message: "오늘은 좋은 일이 생길 거예요",
            luckyColor: .blue,
            luckyNumber: 7
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FortuneEntry) -> ()) {
        // SharedDefaults에서 데이터 읽기
        let sharedDefaults = UserDefaults(suiteName: "group.com.fortune.fortune")
        let entry = FortuneEntry(
            date: Date(),
            fortuneScore: sharedDefaults?.integer(forKey: "fortuneScore") ?? 0,
            message: sharedDefaults?.string(forKey: "message") ?? "",
            luckyColor: Color(hex: sharedDefaults?.string(forKey: "luckyColor") ?? "#000000"),
            luckyNumber: sharedDefaults?.integer(forKey: "luckyNumber") ?? 0
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // 6시간마다 업데이트
        var entries: [FortuneEntry] = []
        let currentDate = Date()
        
        for hourOffset in 0 ..< 4 {
            let entryDate = Calendar.current.date(
                byAdding: .hour, 
                value: hourOffset * 6, 
                to: currentDate
            )!
            
            // API 호출 또는 로컬 데이터 사용
            let entry = fetchFortuneData(for: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

@main
struct FortuneWidget: Widget {
    let kind: String = "FortuneWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FortuneWidgetProvider()) { entry in
            FortuneWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 운세")
        .description("매일 업데이트되는 당신의 운세를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
```

### Widget View 구현
```swift
// FortuneWidgetView.swift
struct FortuneWidgetView: View {
    var entry: FortuneWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallFortuneWidget(entry: entry)
        case .systemMedium:
            MediumFortuneWidget(entry: entry)
        case .accessoryRectangular:
            LockScreenFortuneWidget(entry: entry)
        default:
            Text("Unsupported")
        }
    }
}

struct LockScreenFortuneWidget: View {
    var entry: FortuneWidgetProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("오늘의 운세")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Text(entry.message)
                .font(.caption2)
                .lineLimit(2)
            
            HStack {
                Label("\(entry.fortuneScore)%", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption2)
                
                Spacer()
                
                Circle()
                    .fill(entry.luckyColor)
                    .frame(width: 12, height: 12)
            }
        }
        .foregroundColor(.white)
    }
}
```

## 3️⃣ App Intents & Siri Integration

### Intent Definition
```swift
// DrawTarotIntent.swift
import AppIntents

struct DrawTarotIntent: AppIntent {
    static var title: LocalizedStringResource = "타로 카드 뽑기"
    static var description = IntentDescription("오늘의 타로 카드를 뽑아 운세를 확인합니다")
    
    @Parameter(title: "카드 종류", default: .daily)
    var cardType: TarotCardType
    
    static var parameterSummary: some ParameterSummary {
        Summary("\\(.cardType) 타로 카드 뽑기")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<TarotResult> {
        let tarotService = TarotService()
        let result = try await tarotService.drawCard(type: cardType)
        
        return .result(value: result) {
            TarotResultView(result: result)
        }
    }
}

enum TarotCardType: String, AppEnum {
    case daily = "오늘의 카드"
    case love = "연애운"
    case money = "금전운"
    case work = "직장운"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "타로 카드 종류")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .daily: "오늘의 카드",
        .love: "연애운 카드",
        .money: "금전운 카드",
        .work: "직장운 카드"
    ]
}
```

### Shortcuts Provider
```swift
// FortuneShortcutsProvider.swift
struct FortuneShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DrawTarotIntent(),
            phrases: [
                "\\(.applicationName)에서 타로 카드 뽑기",
                "오늘의 타로 카드 보여줘",
                "\\(.applicationName) 타로"
            ],
            shortTitle: "타로 카드",
            systemImageName: "suit.diamond.fill"
        )
        
        AppShortcut(
            intent: GetFortuneIntent(),
            phrases: [
                "\\(.applicationName)에서 오늘 운세 알려줘",
                "내 운세 어때?",
                "오늘의 운세"
            ],
            shortTitle: "오늘의 운세",
            systemImageName: "star.fill"
        )
    }
}
```

## 4️⃣ Apple Watch App

### Watch App Structure
```
WatchApp/
├── FortuneWatchApp.swift
├── Views/
│   ├── ContentView.swift
│   ├── FortuneDetailView.swift
│   └── QuickActionView.swift
├── ComplicationController.swift
└── Models/
    └── FortuneData.swift
```

### Watch App Main
```swift
// FortuneWatchApp.swift
import SwiftUI

@main
struct FortuneWatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // 운세 데이터 업데이트
                FortuneDataManager.shared.updateFortune {
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                }
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
```

### Complication Support
```swift
// ComplicationController.swift
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let fortuneData = FortuneDataManager.shared.currentFortune
        let template = createTemplate(for: complication.family, data: fortuneData)
        
        let entry = CLKComplicationTimelineEntry(
            date: Date(),
            complicationTemplate: template
        )
        handler(entry)
    }
    
    private func createTemplate(
        for family: CLKComplicationFamily,
        data: FortuneData
    ) -> CLKComplicationTemplate {
        switch family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKTextProvider(format: "\(data.score)%")
            template.line2TextProvider = CLKTextProvider(format: data.emoji)
            return template
            
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularStackText()
            template.line1TextProvider = CLKTextProvider(format: data.emoji)
            template.line2TextProvider = CLKTextProvider(format: "\(data.score)")
            return template
            
        default:
            return CLKComplicationTemplateGraphicCircularView(
                FortuneComplicationView(data: data)
            )
        }
    }
}
```

## 5️⃣ iOS 18 Home Screen Customization

### Dynamic App Icon
```swift
// AppIconManager.swift
import UIKit

class AppIconManager {
    static let shared = AppIconManager()
    
    func updateIcon(for luckyColor: String) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        let iconName = getIconName(for: luckyColor)
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change app icon: \(error)")
            }
        }
    }
    
    private func getIconName(for color: String) -> String? {
        switch color {
        case "#FF6B6B": return "AppIcon-Red"
        case "#4ECDC4": return "AppIcon-Teal"
        case "#FFE66D": return "AppIcon-Yellow"
        case "#A8E6CF": return "AppIcon-Green"
        case "#C7CEEA": return "AppIcon-Purple"
        default: return nil
        }
    }
}
```

### Control Widgets (iOS 18)
```swift
// FortuneControlWidget.swift
import WidgetKit
import SwiftUI

struct FortuneControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: "com.fortune.quickDraw",
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: DrawTarotIntent()) {
                Label("타로 뽑기", systemImage: "sparkles")
            }
        }
        .displayName("빠른 타로")
        .description("탭하여 타로 카드를 뽑으세요")
    }
}
```

## 🔧 Flutter Integration

### Platform Channel Setup
```dart
// ios_native_service.dart
class IOSNativeService {
  static const _channel = MethodChannel('com.fortune.fortune/ios');
  
  // Live Activity 시작
  Future<void> startLiveActivity(FortuneData data) async {
    try {
      await _channel.invokeMethod('startLiveActivity', {
        'fortuneScore': data.score,
        'message': data.message,
        'luckyColor': data.luckyColor,
        'userName': data.userName,
        'fortuneType': data.type,
      });
    } catch (e) {
      Logger.error('Failed to start live activity', e);
    }
  }
  
  // Widget 데이터 업데이트
  Future<void> updateWidget(FortuneData data) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'fortuneScore': data.score,
        'message': data.message,
        'luckyColor': data.luckyColor,
        'luckyNumber': data.luckyNumber,
      });
    } catch (e) {
      Logger.error('Failed to update widget', e);
    }
  }
  
  // 앱 아이콘 변경
  Future<void> changeAppIcon(String colorHex) async {
    try {
      await _channel.invokeMethod('changeAppIcon', {
        'color': colorHex,
      });
    } catch (e) {
      Logger.error('Failed to change app icon', e);
    }
  }
}
```

### Native Swift Handler
```swift
// SwiftFlutterPlugin.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.fortune.fortune/ios",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "startLiveActivity":
                self?.handleStartLiveActivity(call: call, result: result)
            case "updateWidget":
                self?.handleUpdateWidget(call: call, result: result)
            case "changeAppIcon":
                self?.handleChangeAppIcon(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## 📱 Testing & Debugging

### Widget Testing
```bash
# Widget Extension 빌드
xcodebuild -scheme FortuneWidgetExtension -configuration Debug

# 시뮬레이터에서 위젯 테스트
xcrun simctl install booted path/to/Fortune.app
```

### Live Activity Testing
```swift
// Debug 모드에서 Live Activity 테스트
#if DEBUG
struct LiveActivityPreview: PreviewProvider {
    static var previews: some View {
        FortuneActivityAttributes.preview(
            contentState: .init(
                fortuneScore: 85,
                message: "오늘은 행운이 가득한 날!",
                luckyColor: "#FF6B6B"
            ),
            attributes: .init(
                userName: "테스트",
                fortuneType: "일일 운세"
            )
        )
    }
}
#endif
```

## 🚀 Deployment Checklist

1. **App Groups 설정**
   - Capability에서 App Groups 추가
   - `group.com.fortune.fortune` 생성

2. **Widget Extension 추가**
   - File > New > Target > Widget Extension
   - Bundle ID: `com.fortune.fortune.widget`

3. **Watch App 추가**
   - File > New > Target > watchOS App
   - Bundle ID: `com.fortune.fortune.watchkitapp`

4. **Info.plist 업데이트**
   - Widget 설명 추가
   - Siri 사용 권한 추가
   - Background modes 설정

5. **App Store Connect 설정**
   - Widget 스크린샷 준비
   - Watch 앱 스크린샷 준비
   - What's New에 기능 소개

이 가이드를 따라 iOS 네이티브 기능을 구현하면, Fortune 앱이 사용자의 일상에 완벽하게 통합되는 프리미엄 경험을 제공할 수 있습니다.