# iOS Native Features Implementation Guide

## Table of Contents

1. [Project Setup](#project-setup)
2. [Lock Screen Widgets](#lock-screen-widgets)
3. [Dynamic Island & Live Activities](#dynamic-island--live-activities)
4. [Siri Integration & App Intents](#siri-integration--app-intents)
5. [Apple Watch App](#apple-watch-app)
6. [iOS 18 Home Screen Features](#ios-18-home-screen-features)
7. [Implementation Examples](#implementation-examples)

## Project Setup

### 1. Update iOS Project Structure

```
ios/
├── Runner/
├── FortuneWidgetExtension/
│   ├── Info.plist
│   ├── FortuneWidget.swift
│   ├── FortuneWidgetBundle.swift
│   ├── Providers/
│   └── Views/
├── FortuneWatchApp/
│   ├── Info.plist
│   ├── FortuneApp.swift
│   └── Views/
└── Shared/
    ├── Models/
    ├── Services/
    └── Resources/
```

### 2. Update Podfile

```ruby
platform :ios, '14.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Shared pods
  pod 'SwiftProtobuf'
end

target 'FortuneWidgetExtension' do
  use_frameworks!
  
  # Widget specific pods
  pod 'SwiftProtobuf'
end

target 'FortuneWatchApp Watch App' do
  platform :watchos, '9.0'
  use_frameworks!
  
  # Watch specific pods
end
```

### 3. Configure App Groups

Enable App Groups in Xcode for data sharing:
- App Group ID: `group.com.fortune.shared`
- Enable for: Runner, Widget Extension, Watch App

## Lock Screen Widgets

### 1. Widget Extension Setup

Create `FortuneWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct FortuneEntry: TimelineEntry {
    let date: Date
    let fortune: FortuneData
    let configuration: ConfigurationIntent
}

struct FortuneData {
    let dailyScore: Int
    let message: String
    let luckyNumbers: [Int]
    let luckyColor: Color
    let element: String
}

struct FortuneWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> FortuneEntry {
        FortuneEntry(
            date: Date(),
            fortune: FortuneData.placeholder(),
            configuration: ConfigurationIntent()
        )
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, 
                    in context: Context, 
                    completion: @escaping (FortuneEntry) -> ()) {
        let entry = FortuneEntry(
            date: Date(),
            fortune: FortuneData.current(),
            configuration: configuration
        )
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent,
                    in context: Context,
                    completion: @escaping (Timeline<FortuneEntry>) -> ()) {
        Task {
            let fortunes = await FortuneService.shared.fetchDailyFortunes()
            let entries = createTimelineEntries(from: fortunes, configuration: configuration)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}
```

### 2. Widget Views

Small Widget (Accessory Circular):

```swift
struct SmallFortuneWidget: View {
    let entry: FortuneEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                Text("\(entry.fortune.dailyScore)")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}
```

Medium Widget (Accessory Rectangular):

```swift
struct MediumFortuneWidget: View {
    let entry: FortuneEntry
    
    var body: some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundColor(entry.fortune.luckyColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Fortune")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.fortune.message)
                    .font(.caption2)
                    .lineLimit(2)
                HStack {
                    ForEach(entry.fortune.luckyNumbers.prefix(3), id: \.self) { number in
                        Text("\(number)")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(Capsule().fill(.secondary.opacity(0.3)))
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
```

### 3. Widget Configuration

```swift
@main
struct FortuneWidgetBundle: WidgetBundle {
    var body: some Widget {
        FortuneWidget()
        FortuneComplicationWidget()
        FiveElementsWidget()
        ZodiacCompatibilityWidget()
    }
}

struct FortuneWidget: Widget {
    let kind: String = "FortuneWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: FortuneWidgetProvider()
        ) { entry in
            FortuneWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Fortune")
        .description("Your daily fortune at a glance")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .systemSmall,
            .systemMedium
        ])
    }
}
```

## Dynamic Island & Live Activities

### 1. Live Activity Setup

Create `FortuneLiveActivity.swift`:

```swift
import ActivityKit
import WidgetKit
import SwiftUI

struct FortuneLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var fortuneScore: Int
        var timeRemaining: Int
        var luckyMoment: Date?
        var currentElement: String
    }
    
    var userName: String
    var startTime: Date
}

struct FortuneLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FortuneLiveActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    ElementIcon(element: context.state.currentElement)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    FortuneScoreView(score: context.state.fortuneScore)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Fortune Active")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    FortuneProgressView(context: context)
                }
            } compactLeading: {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            } compactTrailing: {
                Text("\(context.state.fortuneScore)")
                    .font(.caption2)
                    .foregroundColor(.green)
            } minimal: {
                Image(systemName: "moon.stars")
                    .foregroundColor(.yellow)
            }
        }
    }
}
```

### 2. Starting Live Activities

In your Flutter platform channel handler:

```swift
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<FortuneLiveActivityAttributes>?
    
    func startFortuneTracking(userName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = FortuneLiveActivityAttributes(
            userName: userName,
            startTime: Date()
        )
        
        let initialState = FortuneLiveActivityAttributes.ContentState(
            fortuneScore: 75,
            timeRemaining: 3600,
            luckyMoment: nil,
            currentElement: "Fire"
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: .token
            )
            
            // Send push token to server
            if let pushToken = currentActivity?.pushToken {
                Task {
                    await FortuneService.shared.registerPushToken(pushToken)
                }
            }
        } catch {
            print("Error starting live activity: \(error)")
        }
    }
    
    func updateFortuneScore(_ score: Int, element: String) {
        Task {
            guard let activity = currentActivity else { return }
            
            let updatedState = FortuneLiveActivityAttributes.ContentState(
                fortuneScore: score,
                timeRemaining: calculateTimeRemaining(),
                luckyMoment: checkLuckyMoment(),
                currentElement: element
            )
            
            await activity.update(using: updatedState)
        }
    }
}
```

## Siri Integration & App Intents

### 1. App Intent Definition

Create `FortuneAppIntents.swift`:

```swift
import AppIntents
import SwiftUI

struct GetDailyFortuneIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Daily Fortune"
    static var description = IntentDescription("Get your daily fortune reading")
    
    @Parameter(title: "Fortune Type")
    var fortuneType: FortuneType?
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let fortune = try await FortuneService.shared.getDailyFortune(type: fortuneType)
        
        return .result(
            dialog: IntentDialog(fortune.spokenMessage),
            view: FortuneSnippetView(fortune: fortune)
        )
    }
}

struct CheckCompatibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Zodiac Compatibility"
    
    @Parameter(title: "Your Sign", requestValueDialog: "What's your zodiac sign?")
    var yourSign: ZodiacSign
    
    @Parameter(title: "Their Sign", requestValueDialog: "What's their zodiac sign?")
    var theirSign: ZodiacSign
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let compatibility = try await FortuneService.shared.checkCompatibility(
            sign1: yourSign,
            sign2: theirSign
        )
        
        return .result(
            dialog: IntentDialog(compatibility.message)
        )
    }
}

// App Shortcuts
struct FortuneShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetDailyFortuneIntent(),
            phrases: [
                "Get my fortune in \(.applicationName)",
                "What's my fortune today in \(.applicationName)",
                "Show my daily fortune in \(.applicationName)"
            ],
            shortTitle: "Daily Fortune",
            systemImageName: "moon.stars"
        )
        
        AppShortcut(
            intent: CheckCompatibilityIntent(),
            phrases: [
                "Check compatibility in \(.applicationName)",
                "Zodiac match in \(.applicationName)"
            ],
            shortTitle: "Check Compatibility",
            systemImageName: "heart.circle"
        )
    }
}
```

### 2. Siri Snippet Views

```swift
struct FortuneSnippetView: View {
    let fortune: Fortune
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Today's Fortune")
                    .font(.headline)
                Spacer()
                Text("\(fortune.score)/100")
                    .font(.title2)
                    .foregroundColor(fortune.scoreColor)
            }
            
            Text(fortune.message)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Label("Lucky Numbers", systemImage: "number.circle")
                    .font(.caption)
                Spacer()
                ForEach(fortune.luckyNumbers, id: \.self) { number in
                    Text("\(number)")
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(Color.yellow.opacity(0.3)))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}
```

## Apple Watch App

### 1. Watch App Structure

Create `FortuneApp.swift`:

```swift
import SwiftUI

@main
struct FortuneWatchApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainFortuneView()
            }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "fortune")
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        // Setup watch connectivity
        WatchConnectivityManager.shared.setup()
        
        // Schedule background tasks
        scheduleBackgroundRefresh()
    }
    
    func scheduleBackgroundRefresh() {
        let preferredDate = Date().addingTimeInterval(3600) // 1 hour
        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: preferredDate,
            userInfo: nil
        ) { error in
            if let error = error {
                print("Error scheduling refresh: \(error)")
            }
        }
    }
}
```

### 2. Watch Complications

```swift
import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "DailyFortune",
                displayName: "Daily Fortune",
                supportedFamilies: [
                    .circularSmall,
                    .modularSmall,
                    .utilitarianSmall,
                    .graphicCircular,
                    .graphicRectangular,
                    .graphicExtraLarge
                ]
            )
        ]
        handler(descriptors)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        Task {
            let fortune = await FortuneService.shared.getCurrentFortune()
            let template = makeTemplate(for: complication.family, fortune: fortune)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        }
    }
    
    func makeTemplate(for family: CLKComplicationFamily, fortune: Fortune) -> CLKComplicationTemplate {
        switch family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularStackImage(
                line1ImageProvider: CLKFullColorImageProvider(
                    fullColorImage: UIImage(systemName: "sparkles")!
                ),
                line2TextProvider: CLKTextProvider(
                    format: "\(fortune.score)"
                )
            )
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKTextProvider(format: "Fortune"),
                body1TextProvider: CLKTextProvider(format: fortune.shortMessage),
                body2TextProvider: CLKTextProvider(
                    format: "Lucky: \(fortune.luckyNumbers.map(String.init).joined(separator: ", "))"
                )
            )
            
        default:
            return CLKComplicationTemplateModularSmallStackText(
                line1TextProvider: CLKTextProvider(format: "Fortune"),
                line2TextProvider: CLKTextProvider(format: "\(fortune.score)")
            )
        }
    }
}
```

### 3. Watch UI Components

```swift
struct MainFortuneView: View {
    @StateObject private var viewModel = FortuneWatchViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Fortune Score Card
                FortuneScoreCard(score: viewModel.currentScore)
                    .frame(height: 100)
                
                // Quick Actions
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "number",
                        title: "Lucky #",
                        action: viewModel.showLuckyNumbers
                    )
                    
                    QuickActionButton(
                        icon: "moon.stars",
                        title: "Zodiac",
                        action: viewModel.showZodiac
                    )
                }
                
                // Fortune Message
                Text(viewModel.fortuneMessage)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                // Elements View
                FiveElementsCompactView(elements: viewModel.elements)
            }
            .padding()
        }
        .navigationTitle("Fortune")
        .onAppear {
            viewModel.refreshFortune()
        }
    }
}

struct FortuneScoreCard: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(scoreGradient)
            
            VStack {
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold))
                Text("Today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var scoreGradient: LinearGradient {
        LinearGradient(
            colors: score > 70 ? [.green, .yellow] : [.orange, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

## iOS 18 Home Screen Features

### 1. Control Center Widget

```swift
import WidgetKit
import SwiftUI
import AppIntents

struct FortuneControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "FortuneControl"
        ) {
            ControlWidgetButton(action: RefreshFortuneIntent()) {
                Label("Refresh Fortune", systemImage: "arrow.clockwise")
            }
        }
        .displayName("Fortune Refresh")
        .description("Quickly refresh your daily fortune")
    }
}

struct RefreshFortuneIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Fortune"
    
    func perform() async throws -> some IntentResult {
        try await FortuneService.shared.refreshDailyFortune()
        return .result()
    }
}
```

### 2. Interactive Widgets

```swift
struct InteractiveFortuneWidget: View {
    @AppStorage("widget_fortune_type") private var fortuneType: String = "daily"
    let entry: FortuneEntry
    
    var body: some View {
        VStack {
            // Widget Header with Toggle
            HStack {
                Text("Fortune")
                    .font(.headline)
                Spacer()
                
                Button(intent: ToggleFortuneTypeIntent()) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            // Dynamic Content based on type
            Group {
                switch fortuneType {
                case "daily":
                    DailyFortuneView(fortune: entry.fortune)
                case "love":
                    LoveFortuneView(fortune: entry.fortune)
                case "career":
                    CareerFortuneView(fortune: entry.fortune)
                default:
                    DailyFortuneView(fortune: entry.fortune)
                }
            }
            .transition(.slide)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}
```

## Implementation Examples

### 1. Platform Channel Setup

In `AppDelegate.swift`:

```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup platform channels
    setupPlatformChannels()
    
    // Setup Live Activities
    LiveActivityManager.shared.setup()
    
    // Setup Watch Connectivity
    if WCSession.isSupported() {
        WCSession.default.delegate = WatchConnectivityManager.shared
        WCSession.default.activate()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}

private func setupPlatformChannels() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    
    let fortuneChannel = FlutterMethodChannel(
        name: "com.fortune.ios/native_features",
        binaryMessenger: controller.binaryMessenger
    )
    
    fortuneChannel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "startLiveActivity":
            self?.handleStartLiveActivity(call: call, result: result)
        case "updateWidget":
            self?.handleUpdateWidget(call: call, result: result)
        case "sendToWatch":
            self?.handleSendToWatch(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
```

### 2. Widget Update from Flutter

Flutter side:

```dart
class IOSNativeFeatures {
  static const _channel = MethodChannel('com.fortune.ios/native_features');
  
  static Future<void> updateWidget({
    required int fortuneScore,
    required String message,
    required List<int> luckyNumbers,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'fortuneScore': fortuneScore,
        'message': message,
        'luckyNumbers': luckyNumbers,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
  
  static Future<void> startLiveActivity({
    required String userName,
    required int initialScore,
  }) async {
    try {
      await _channel.invokeMethod('startLiveActivity', {
        'userName': userName,
        'initialScore': initialScore,
      });
    } catch (e) {
      print('Error starting live activity: $e');
    }
  }
}
```

## Best Practices

### 1. Performance Optimization
- Use timeline-based updates for widgets
- Cache fortune data in shared container
- Optimize image assets for each widget size
- Implement proper background task handling

### 2. User Experience
- Provide meaningful placeholders
- Handle offline scenarios gracefully
- Respect user's widget configuration
- Follow Apple's Human Interface Guidelines

### 3. Testing
- Test on various iOS versions
- Test widget gallery presentation
- Verify Siri commands in different languages
- Test Watch complications on all watch faces

### 4. App Store Considerations
- Provide widget gallery screenshots
- Document Siri commands in app description
- Include Watch app screenshots
- Follow widget content guidelines

## Troubleshooting

### Common Issues

1. **Widget Not Updating**
   - Check App Group configuration
   - Verify timeline policy
   - Check background refresh settings

2. **Live Activity Not Starting**
   - Verify Info.plist configuration
   - Check user permissions
   - Ensure proper push notification setup

3. **Watch Connectivity Issues**
   - Verify both apps are installed
   - Check WCSession activation
   - Handle reachability properly

## Next Steps

1. Implement shared data layer
2. Create widget UI designs
3. Set up push notification infrastructure
4. Test on physical devices
5. Submit for App Store review