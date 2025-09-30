# Native Features Implementation Guide

A comprehensive, feature-organized guide for implementing native platform features in the Fortune Flutter app.

## Table of Contents

1. [Overview & Feature Matrix](#overview--feature-matrix)
2. [Home Screen Widgets](#home-screen-widgets)
3. [Lock Screen Features](#lock-screen-features)
4. [Dynamic Island & Live Activities](#dynamic-island--live-activities)
5. [Voice Assistant Integration](#voice-assistant-integration)
6. [Wearable Device Support](#wearable-device-support)
7. [Dynamic Theming](#dynamic-theming)
8. [Advanced Notifications](#advanced-notifications)
9. [Platform Channel Integration](#platform-channel-integration)
10. [Common Patterns & Best Practices](#common-patterns--best-practices)

---

## Overview & Feature Matrix

### Platform Availability

| Feature | iOS | Android | iOS Min Version | Android Min API |
|---------|-----|---------|-----------------|-----------------|
| **Home Screen Widgets** | ✅ | ✅ | iOS 14 | API 21 |
| **Lock Screen Widgets** | ✅ | ❌ | iOS 16 | - |
| **Dynamic Island** | ✅ | ❌ | iOS 16.1 (iPhone 14 Pro+) | - |
| **Live Activities** | ✅ | ❌ | iOS 16.1 | - |
| **Voice Assistant** | ✅ Siri | ✅ Google Assistant | iOS 16 | API 23 |
| **Watch App** | ✅ Apple Watch | ✅ Wear OS | watchOS 9 | Wear OS 3.0 |
| **Dynamic Theming** | ❌ | ✅ Material You | - | API 31 (Android 12) |
| **Rich Notifications** | ✅ | ✅ | iOS 14 | API 23 |

### Architecture Overview

```
Flutter App (Dart)
    ↕️ Method Channels
    |
    ├── iOS Native (Swift)
    │   ├── Widget Extensions (WidgetKit)
    │   ├── Live Activities (ActivityKit)
    │   ├── App Intents (Siri)
    │   └── Watch App (WatchKit)
    |
    └── Android Native (Kotlin)
        ├── Home Screen Widgets (Glance)
        ├── Notifications (NotificationCompat)
        ├── Wear OS App (Compose for Wear)
        └── Dynamic Theme (Material You)
```

### Core Design Principles

1. **Modular Architecture**: Separate native features into independent modules
2. **Shared Business Logic**: Reuse Flutter logic through platform channels
3. **Native Performance**: Use native implementations for UI-intensive features
4. **Consistent Branding**: Maintain Fortune app identity across all platforms
5. **Graceful Degradation**: Handle older OS versions and unavailable features

---

## Home Screen Widgets

Provide quick access to fortune information directly from the device home screen.

### iOS Implementation

#### Widget Configuration

**Available Widget Families**:
- `systemSmall`: Compact fortune score (2x2)
- `systemMedium`: Score + lucky numbers (4x2)
- `systemLarge`: Full fortune card with message (4x4)

**Implementation Structure**:

```swift
// FortuneWidget.swift
import WidgetKit
import SwiftUI

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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Timeline Provider
struct FortuneWidgetProvider: IntentTimelineProvider {
    func getTimeline(for configuration: ConfigurationIntent,
                    in context: Context,
                    completion: @escaping (Timeline<FortuneEntry>) -> ()) {
        Task {
            let fortunes = await FortuneService.shared.fetchDailyFortunes()
            let entries = createTimelineEntries(from: fortunes, configuration: configuration)

            // Update at midnight each day
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

// Widget Views
struct SmallFortuneWidget: View {
    let entry: FortuneEntry

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.title2)
            Text("\(entry.fortune.dailyScore)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(entry.fortune.scoreColor)
            Text("Today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}
```

**Key Features**:
- Timeline-based updates (daily at midnight)
- App Group for data sharing: `group.com.fortune.shared`
- Intent configuration for customization
- Multiple size variants

### Android Implementation

#### Widget Configuration with Glance

**Available Widget Sizes**:
- Small (2x2): Fortune score circle
- Medium (4x2): Score + lucky numbers
- Large (4x4): Full fortune card with message

**Implementation Structure**:

```kotlin
// FortuneGlanceWidget.kt
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class FortuneWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = FortuneGlanceWidget()
}

class FortuneGlanceWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            FortuneWidgetContent()
        }
    }

    @Composable
    fun FortuneWidgetContent() {
        val fortuneData = currentState<FortuneData>() ?: FortuneData.default()
        val size = LocalSize.current

        GlanceTheme {
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(ImageProvider(R.drawable.widget_background))
                    .clickable(actionRunCallback<OpenAppAction>())
                    .padding(16.dp)
            ) {
                when (size) {
                    is SmallSize -> SmallFortuneWidget(fortuneData)
                    is MediumSize -> MediumFortuneWidget(fortuneData)
                    is LargeSize -> LargeFortuneWidget(fortuneData)
                }
            }
        }
    }
}

// Widget Configuration Activity
class FortuneWidgetConfigActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                WidgetConfigurationScreen(
                    onConfigurationComplete = { config ->
                        saveWidgetConfiguration(config)
                        updateWidget()
                        finishConfiguration()
                    }
                )
            }
        }
    }
}
```

**Key Features**:
- Jetpack Glance for modern Compose UI
- WorkManager for periodic updates
- Configuration activity for customization
- Material Design 3 theming

### Flutter Integration

```dart
// lib/services/widget_service.dart
class WidgetService {
  static const _channel = MethodChannel('com.fortune/widgets');

  static Future<void> updateWidgets({
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
      Logger.warning('Failed to update widgets: $e');
    }
  }
}
```

### Best Practices

**Performance**:
- Update widgets only when data changes
- Use cached images for widget backgrounds
- Implement proper timeline policies
- Batch updates when multiple widgets exist

**User Experience**:
- Provide meaningful placeholder content
- Support both light and dark modes
- Handle data loading states gracefully
- Respect user's widget size preferences

**Battery Optimization**:
- Schedule updates during device idle time
- Use exponential backoff for failed updates
- Minimize network requests
- Cache fortune data locally

---

## Lock Screen Features

iOS-exclusive features for displaying fortune information on the lock screen.

### iOS Lock Screen Widgets (iOS 16+)

#### Widget Families

1. **Accessory Circular**: Compact circular widget
2. **Accessory Rectangular**: Banner-style widget
3. **Accessory Inline**: Single line of text above the clock

#### Implementation

```swift
// Lock Screen Widget Configuration
struct FortuneWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: "FortuneWidget",
            intent: ConfigurationIntent.self,
            provider: FortuneWidgetProvider()
        ) { entry in
            FortuneWidgetEntryView(entry: entry)
        }
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// Circular Lock Screen Widget
struct CircularFortuneWidget: View {
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
        .widgetLabel {
            Text("Fortune: \(entry.fortune.dailyScore)")
        }
    }
}

// Rectangular Lock Screen Widget
struct RectangularFortuneWidget: View {
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
            }
        }
        .padding(.vertical, 4)
    }
}

// Inline Lock Screen Widget
struct InlineFortuneWidget: View {
    let entry: FortuneEntry

    var body: some View {
        Text("✨ Fortune: \(entry.fortune.dailyScore) | Lucky: \(entry.fortune.luckyNumbers.first ?? 0)")
    }
}
```

### Key Features

- **Glanceable Information**: Quick fortune score at a glance
- **Automatic Updates**: Timeline refreshes at midnight
- **Privacy-Conscious**: Shows minimal sensitive information
- **Always-On Display**: Visible without unlocking device

### Best Practices

**Content Guidelines**:
- Keep text concise and readable
- Use symbols and icons effectively
- Avoid sensitive personal information
- Design for monochrome rendering

**Performance**:
- Optimize for battery efficiency
- Use system colors for tinting
- Minimize animation and transitions
- Cache rendered content

---

## Dynamic Island & Live Activities

Real-time fortune tracking for iPhone 14 Pro and later (iOS 16.1+).

### Dynamic Island Implementation

Display live fortune updates in the Dynamic Island interface.

```swift
// FortuneLiveActivity.swift
import ActivityKit
import WidgetKit

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
            // Lock Screen/Banner UI
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading) {
                    Text("Fortune Active")
                        .font(.caption)
                    Text("Score: \(context.state.fortuneScore)")
                        .font(.caption2)
                }
                Spacer()
                Text("\(context.state.timeRemaining)m left")
                    .font(.caption)
            }
            .padding()
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
                // Compact Leading (left side of notch)
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            } compactTrailing: {
                // Compact Trailing (right side of notch)
                Text("\(context.state.fortuneScore)")
                    .font(.caption2)
                    .foregroundColor(.green)
            } minimal: {
                // Minimal (when multiple activities are active)
                Image(systemName: "moon.stars")
                    .foregroundColor(.yellow)
            }
        }
    }
}
```

### Starting and Managing Live Activities

```swift
// LiveActivityManager.swift
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

            // Send push token to server for remote updates
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

    func endFortuneTracking() {
        Task {
            await currentActivity?.end(dismissalPolicy: .default)
            currentActivity = nil
        }
    }
}
```

### Flutter Integration

```dart
// lib/services/ios_live_activity_service.dart
class IOSLiveActivityService {
  static const _channel = MethodChannel('com.fortune.ios/live_activity');

  static Future<void> startFortuneTracking({
    required String userName,
    required int initialScore,
  }) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('startLiveActivity', {
        'userName': userName,
        'initialScore': initialScore,
      });
    } catch (e) {
      Logger.warning('Failed to start live activity: $e');
    }
  }

  static Future<void> updateFortuneScore({
    required int score,
    required String element,
  }) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('updateLiveActivity', {
        'score': score,
        'element': element,
      });
    } catch (e) {
      Logger.warning('Failed to update live activity: $e');
    }
  }

  static Future<void> endFortuneTracking() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('endLiveActivity');
    } catch (e) {
      Logger.warning('Failed to end live activity: $e');
    }
  }
}
```

### Use Cases

1. **Daily Fortune Countdown**: Track time until next fortune refresh
2. **Lucky Streak Tracking**: Monitor consecutive lucky days
3. **Achievement Progress**: Show progress toward fortune milestones
4. **Lucky Time Window**: Alert users during their lucky moments

### Best Practices

**Content Design**:
- Design for all Dynamic Island states
- Provide meaningful minimal state representation
- Use animations sparingly
- Test on various iPhone models

**Performance**:
- Update only when necessary
- Use push notifications for remote updates
- Handle activity lifecycle properly
- Respect 8-hour maximum duration

**User Experience**:
- Request permission appropriately
- Explain activity benefits clearly
- Allow users to dismiss easily
- Provide actionable content

---

## Voice Assistant Integration

Enable users to query their fortune using voice commands.

### iOS Siri Integration (iOS 16+)

#### App Intent Definition

```swift
// FortuneAppIntents.swift
import AppIntents
import SwiftUI

struct GetDailyFortuneIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Daily Fortune"
    static var description = IntentDescription("Get your daily fortune reading")
    static var openAppWhenRun: Bool = false

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
                "Show my daily fortune"
            ],
            shortTitle: "Daily Fortune",
            systemImageName: "moon.stars"
        )
    }
}
```

#### Siri Snippet View

```swift
// FortuneSnippetView.swift
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
    }
}
```

### Android Google Assistant Integration

#### App Actions Definition

```xml
<!-- res/xml/app_actions.xml -->
<actions>
    <action intentName="actions.intent.GET_THING">
        <fulfillment urlTemplate="fortune://daily">
            <parameter-mapping
                intentParameter="thing.name"
                urlParameter="type" />
        </fulfillment>

        <entity-set-reference entitySetId="FortuneThing" />
    </action>

    <entity-set entitySetId="FortuneThing">
        <entity
            identifier="daily"
            name="@string/fortune_daily"
            alternateName="@array/fortune_daily_synonyms" />
        <entity
            identifier="love"
            name="@string/fortune_love"
            alternateName="@array/fortune_love_synonyms" />
    </entity-set>
</actions>
```

#### Deep Link Handling

```kotlin
// MainActivity.kt
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        when (intent.action) {
            Intent.ACTION_VIEW -> {
                val data = intent.data
                if (data?.scheme == "fortune") {
                    val fortuneType = data.host ?: "daily"
                    navigateToFortune(fortuneType)
                }
            }
        }
    }
}
```

### Supported Voice Commands

**iOS Siri**:
- "Hey Siri, what's my fortune today?"
- "Hey Siri, show my lucky numbers in Fortune"
- "Hey Siri, check compatibility with Leo in Fortune"

**Android Google Assistant**:
- "Hey Google, get my daily fortune"
- "Hey Google, show me my love fortune"
- "Hey Google, what are my lucky numbers?"

### Best Practices

**Response Design**:
- Provide concise spoken responses
- Include visual snippet views
- Handle errors gracefully
- Support parameter disambiguation

**User Experience**:
- Test with various phrasings
- Support multiple languages
- Provide helpful error messages
- Don't require app launch for simple queries

---

## Wearable Device Support

Extend the Fortune experience to wearable devices.

### Apple Watch Implementation (watchOS 9+)

#### Watch App Structure

```swift
// FortuneWatchApp.swift
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

// Main Watch View
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
                        title: "Lucky #"
                    )
                    QuickActionButton(
                        icon: "moon.stars",
                        title: "Zodiac"
                    )
                }

                // Fortune Message
                Text(viewModel.fortuneMessage)
                    .font(.footnote)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
            }
            .padding()
        }
        .navigationTitle("Fortune")
    }
}
```

#### Watch Complications

```swift
// ComplicationController.swift
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "DailyFortune",
                displayName: "Daily Fortune",
                supportedFamilies: [
                    .circularSmall,
                    .graphicCircular,
                    .graphicRectangular,
                    .graphicExtraLarge
                ]
            )
        ]
        handler(descriptors)
    }

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
                line2TextProvider: CLKTextProvider(format: "\(fortune.score)")
            )
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKTextProvider(format: "Fortune"),
                body1TextProvider: CLKTextProvider(format: fortune.shortMessage)
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

### Wear OS Implementation (Wear OS 3.0+)

#### Wear OS App Structure

```kotlin
// MainActivity.kt (Wear OS)
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            FortuneWearApp()
        }
    }
}

@Composable
fun FortuneWearApp() {
    FortuneWearTheme {
        val navController = rememberSwipeDismissableNavController()

        SwipeDismissableNavHost(
            navController = navController,
            startDestination = "main"
        ) {
            composable("main") {
                MainScreen()
            }
        }
    }
}

@Composable
fun MainScreen() {
    val listState = rememberScalingLazyListState()

    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = { PositionIndicator(scalingLazyListState = listState) }
    ) {
        ScalingLazyColumn(
            modifier = Modifier.fillMaxSize(),
            state = listState,
            autoCentering = AutoCenteringParams(itemIndex = 0)
        ) {
            item {
                FortuneScoreCard(score = 88)
            }
            item {
                Chip(
                    onClick = { },
                    label = { Text("Lucky Numbers") },
                    icon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_numbers),
                            contentDescription = null
                        )
                    }
                )
            }
        }
    }
}
```

#### Wear OS Tiles

```kotlin
// FortuneTileService.kt
class FortuneTileService : TileService() {
    private val serviceScope = CoroutineScope(Dispatchers.IO)

    override fun onTileRequest(requestParams: RequestBuilders.TileRequest): ListenableFuture<Tile> {
        return serviceScope.future {
            Tile.Builder()
                .setResourcesVersion(RESOURCES_VERSION)
                .setTimeline(
                    Timeline.Builder()
                        .addTimelineEntry(
                            TimelineEntry.Builder()
                                .setLayout(createLayout())
                                .build()
                        )
                        .build()
                )
                .build()
        }
    }

    private fun createLayout(): LayoutElement {
        val fortune = getLatestFortune()

        return Box.Builder()
            .setWidth(expand())
            .setHeight(expand())
            .addContent(
                Column.Builder()
                    .addContent(
                        Text.Builder()
                            .setText("${fortune.score}/100")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(sp(24f))
                                    .setWeight(FONT_WEIGHT_BOLD)
                                    .build()
                            )
                            .build()
                    )
                    .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
                    .build()
            )
            .build()
    }
}
```

#### Wear OS Complications

```kotlin
// FortuneComplicationService.kt
class FortuneComplicationService : SuspendingComplicationDataSourceService() {
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val fortune = FortuneDataProvider.getCurrentFortune()

        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(
                text = PlainComplicationText.Builder("${fortune.score}").build(),
                contentDescription = PlainComplicationText.Builder("Fortune score").build()
            )
            .setTitle(PlainComplicationText.Builder("Fortune").build())
            .setTapAction(createOpenAppIntent())
            .build()

            ComplicationType.RANGED_VALUE -> RangedValueComplicationData.Builder(
                value = fortune.score.toFloat(),
                min = 0f,
                max = 100f,
                contentDescription = PlainComplicationText.Builder("Fortune score").build()
            )
            .setText(PlainComplicationText.Builder("${fortune.score}").build())
            .build()

            else -> null
        }
    }
}
```

### Data Synchronization

#### iOS Watch Connectivity

```swift
// WatchConnectivityManager.swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    private var session: WCSession?

    func setup() {
        guard WCSession.isSupported() else { return }

        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    func sendFortuneUpdate(_ fortune: Fortune) {
        guard let session = session, session.isReachable else { return }

        let data: [String: Any] = [
            "score": fortune.score,
            "message": fortune.message,
            "luckyNumbers": fortune.luckyNumbers,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(data, replyHandler: nil) { error in
            print("Error sending to watch: \(error)")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated: \(activationState.rawValue)")
    }
}
```

#### Android Wear Data Layer

```kotlin
// WearDataManager.kt
class WearDataManager(private val context: Context) {
    private val dataClient = Wearable.getDataClient(context)

    suspend fun sendFortuneUpdate(fortune: Fortune) {
        val putDataRequest = PutDataMapRequest.create("/fortune").apply {
            dataMap.putInt("score", fortune.score)
            dataMap.putString("message", fortune.message)
            dataMap.putIntArray("luckyNumbers", fortune.luckyNumbers.toIntArray())
            dataMap.putLong("timestamp", System.currentTimeMillis())
        }.asPutDataRequest()

        try {
            dataClient.putDataItem(putDataRequest).await()
        } catch (e: Exception) {
            Log.e("WearData", "Failed to send data", e)
        }
    }
}
```

### Best Practices

**Design Guidelines**:
- Optimize for small screens
- Use large, tappable targets
- Implement rotary input support (Wear OS)
- Digital Crown support (watchOS)

**Performance**:
- Minimize battery drain
- Cache data locally
- Sync only essential data
- Use complications efficiently

**User Experience**:
- Quick glance interactions
- Minimal text input
- Voice input when appropriate
- Haptic feedback for actions

---

## Dynamic Theming

Adapt app colors based on system wallpaper (Android 12+ Material You).

### Android Material You Implementation

#### Dynamic Color Extraction

```kotlin
// DynamicThemeService.kt
class DynamicThemeService(private val context: Context) {

    @RequiresApi(Build.VERSION_CODES.S)
    fun applyDynamicColors() {
        if (DynamicColors.isDynamicColorAvailable()) {
            DynamicColors.applyToActivitiesIfAvailable(context.applicationContext as Application)
        }
    }

    suspend fun extractWallpaperColors(): FortuneColorScheme = withContext(Dispatchers.IO) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return@withContext getMaterialYouColors()
        } else {
            return@withContext extractPaletteColors()
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun getMaterialYouColors(): FortuneColorScheme {
        val resources = context.resources
        return FortuneColorScheme(
            primary = resources.getColor(android.R.color.system_accent1_500, null),
            secondary = resources.getColor(android.R.color.system_accent2_500, null),
            tertiary = resources.getColor(android.R.color.system_accent3_500, null),
            surface = resources.getColor(android.R.color.system_neutral1_900, null),
            background = resources.getColor(android.R.color.system_neutral1_1000, null)
        )
    }

    private suspend fun extractPaletteColors(): FortuneColorScheme = withContext(Dispatchers.Default) {
        val wallpaperManager = WallpaperManager.getInstance(context)
        val drawable = wallpaperManager.drawable

        if (drawable is BitmapDrawable) {
            val bitmap = drawable.bitmap
            val palette = Palette.from(bitmap).generate()

            return@withContext FortuneColorScheme(
                primary = palette.vibrantSwatch?.rgb ?: palette.dominantSwatch?.rgb ?: 0,
                secondary = palette.mutedSwatch?.rgb ?: palette.dominantSwatch?.rgb ?: 0,
                tertiary = palette.lightVibrantSwatch?.rgb ?: palette.dominantSwatch?.rgb ?: 0,
                surface = palette.darkMutedSwatch?.rgb ?: 0,
                background = palette.darkVibrantSwatch?.rgb ?: 0
            )
        }

        return@withContext FortuneColorScheme.default()
    }
}

data class FortuneColorScheme(
    val primary: Int,
    val secondary: Int,
    val tertiary: Int,
    val surface: Int,
    val background: Int
) {
    companion object {
        fun default() = FortuneColorScheme(
            primary = 0xFFFFD700.toInt(), // Gold
            secondary = 0xFF8B4513.toInt(), // Saddle Brown
            tertiary = 0xFFFF6347.toInt(), // Tomato
            surface = 0xFF2C2C2C.toInt(),
            background = 0xFF1A1A1A.toInt()
        )
    }
}
```

#### Apply to MainActivity

```kotlin
// MainActivity.kt
class MainActivity: FlutterActivity() {
    private lateinit var dynamicThemeService: DynamicThemeService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        dynamicThemeService = DynamicThemeService(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            dynamicThemeService.applyDynamicColors()
        }

        setupPlatformChannels()
    }

    private fun setupPlatformChannels() {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, "com.fortune.android/dynamic_theme").apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getDynamicColors" -> {
                            lifecycleScope.launch {
                                try {
                                    val colors = dynamicThemeService.extractWallpaperColors()
                                    result.success(mapOf(
                                        "primary" to colors.primary,
                                        "secondary" to colors.secondary,
                                        "tertiary" to colors.tertiary,
                                        "surface" to colors.surface,
                                        "background" to colors.background
                                    ))
                                } catch (e: Exception) {
                                    result.error("EXTRACTION_ERROR", e.message, null)
                                }
                            }
                        }
                        else -> result.notImplemented()
                    }
                }
            }
        }
    }
}
```

### Flutter Integration

```dart
// lib/services/dynamic_theme_service.dart
class DynamicThemeService {
  static const _channel = MethodChannel('com.fortune.android/dynamic_theme');

  static Future<ColorScheme?> getDynamicColorScheme() async {
    if (!Platform.isAndroid) return null;

    try {
      final Map<dynamic, dynamic> colors =
          await _channel.invokeMethod('getDynamicColors');

      return ColorScheme(
        primary: Color(colors['primary'] as int),
        secondary: Color(colors['secondary'] as int),
        tertiary: Color(colors['tertiary'] as int),
        surface: Color(colors['surface'] as int),
        background: Color(colors['background'] as int),
        brightness: Brightness.dark,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      );
    } catch (e) {
      Logger.warning('Failed to get dynamic colors: $e');
      return null;
    }
  }
}

// Usage in main app
class FortuneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ColorScheme?>(
      future: DynamicThemeService.getDynamicColorScheme(),
      builder: (context, snapshot) {
        final dynamicColorScheme = snapshot.data;

        return MaterialApp(
          theme: ThemeData(
            colorScheme: dynamicColorScheme ?? ColorScheme.fromSeed(
              seedColor: Color(0xFFFFD700),
            ),
          ),
          home: HomePage(),
        );
      },
    );
  }
}
```

### Best Practices

**Implementation**:
- Check Android version before using Material You
- Provide fallback color scheme for older versions
- Use Palette API for pre-Android 12
- Test with various wallpapers

**Design**:
- Maintain brand identity
- Ensure text readability
- Test in light and dark modes
- Consider accessibility

---

## Advanced Notifications

Rich, interactive notifications with multiple channels and granular control.

### iOS Rich Notifications

#### Notification Content Extension

```swift
// NotificationViewController.swift
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet weak var fortuneScoreLabel: UILabel!
    @IBOutlet weak var fortuneMessageLabel: UILabel!
    @IBOutlet weak var luckyNumbersStackView: UIStackView!

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content

        if let score = content.userInfo["score"] as? Int {
            fortuneScoreLabel.text = "\(score)/100"
        }

        if let message = content.userInfo["message"] as? String {
            fortuneMessageLabel.text = message
        }

        if let numbers = content.userInfo["luckyNumbers"] as? [Int] {
            displayLuckyNumbers(numbers)
        }
    }

    private func displayLuckyNumbers(_ numbers: [Int]) {
        luckyNumbersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        numbers.forEach { number in
            let label = UILabel()
            label.text = "\(number)"
            label.textAlignment = .center
            label.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
            label.layer.cornerRadius = 12
            label.clipsToBounds = true
            luckyNumbersStackView.addArrangedSubview(label)
        }
    }
}
```

#### Notification Actions

```swift
// AppDelegate.swift
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    UNUserNotificationCenter.current().setNotificationCategories([
        createFortuneNotificationCategory()
    ])

    return true
}

func createFortuneNotificationCategory() -> UNNotificationCategory {
    let shareAction = UNNotificationAction(
        identifier: "SHARE_ACTION",
        title: "Share",
        options: [.foreground]
    )

    let viewDetailsAction = UNNotificationAction(
        identifier: "VIEW_DETAILS_ACTION",
        title: "View Details",
        options: [.foreground]
    )

    return UNNotificationCategory(
        identifier: "FORTUNE_CATEGORY",
        actions: [shareAction, viewDetailsAction],
        intentIdentifiers: [],
        options: [.customDismissAction]
    )
}
```

### Android Notification Channels

#### Channel Creation

```kotlin
// NotificationService.kt
class NotificationService(private val context: Context) {
    companion object {
        const val CHANNEL_DAILY_FORTUNE = "daily_fortune"
        const val CHANNEL_LUCKY_TIME = "lucky_time"
        const val CHANNEL_COMPATIBILITY = "compatibility"
        const val CHANNEL_ACHIEVEMENTS = "achievements"
        const val CHANNEL_SPECIAL_EVENTS = "special_events"
    }

    init {
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)

            val channels = listOf(
                NotificationChannel(
                    CHANNEL_DAILY_FORTUNE,
                    "Daily Fortune Updates",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Your daily fortune readings and predictions"
                    enableLights(true)
                    lightColor = context.getColor(R.color.fortune_gold)
                    enableVibration(true)
                },

                NotificationChannel(
                    CHANNEL_LUCKY_TIME,
                    "Lucky Time Alerts",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for your lucky moments"
                    enableLights(true)
                    lightColor = context.getColor(R.color.lucky_green)
                },

                NotificationChannel(
                    CHANNEL_COMPATIBILITY,
                    "Compatibility Matches",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Zodiac compatibility notifications"
                },

                NotificationChannel(
                    CHANNEL_ACHIEVEMENTS,
                    "Fortune Achievements",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Achievement unlocks and milestones"
                },

                NotificationChannel(
                    CHANNEL_SPECIAL_EVENTS,
                    "Special Fortune Events",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Special astrological events"
                    enableLights(true)
                    setBypassDnd(true)
                }
            )

            notificationManager.createNotificationChannels(channels)
        }
    }
}
```

#### Rich Notification Builder

```kotlin
fun showDailyFortuneNotification(fortune: Fortune) {
    val notification = NotificationCompat.Builder(context, CHANNEL_DAILY_FORTUNE)
        .setSmallIcon(R.drawable.ic_notification_fortune)
        .setLargeIcon(BitmapFactory.decodeResource(context.resources, R.drawable.ic_fortune_large))
        .setContentTitle("Your Daily Fortune is Ready! ✨")
        .setContentText("Fortune Score: ${fortune.score}/100")
        .setStyle(NotificationCompat.BigTextStyle()
            .bigText(fortune.detailedMessage)
            .setBigContentTitle("${fortune.zodiacSign} Daily Fortune")
            .setSummaryText("Lucky Numbers: ${fortune.luckyNumbers.joinToString(", ")}")
        )
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setContentIntent(createOpenAppIntent(fortune))
        .setAutoCancel(true)
        .addAction(
            R.drawable.ic_share,
            "Share",
            createShareIntent(fortune)
        )
        .addAction(
            R.drawable.ic_lucky_numbers,
            "Lucky Numbers",
            createLuckyNumbersIntent(fortune)
        )
        .setColor(context.getColor(R.color.fortune_gold))
        .build()

    NotificationManagerCompat.from(context).notify(NOTIFICATION_DAILY_FORTUNE, notification)
}
```

### Notification Scheduling

```kotlin
// NotificationScheduler.kt
class NotificationScheduler(private val context: Context) {
    fun scheduleDailyFortuneNotification(hour: Int, minute: Int) {
        val currentTime = Calendar.getInstance()
        val targetTime = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)

            if (before(currentTime)) {
                add(Calendar.DAY_OF_MONTH, 1)
            }
        }

        val initialDelay = targetTime.timeInMillis - currentTime.timeInMillis

        val dailyWorkRequest = PeriodicWorkRequestBuilder<DailyFortuneWorker>(
            1, TimeUnit.DAYS
        )
            .setInitialDelay(initialDelay, TimeUnit.MILLISECONDS)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "daily_fortune_notification",
            ExistingPeriodicWorkPolicy.REPLACE,
            dailyWorkRequest
        )
    }
}
```

### Flutter Integration

```dart
// lib/services/notification_service.dart
class NotificationService {
  static const _channel = MethodChannel('com.fortune/notifications');

  static Future<void> scheduleDailyNotification({
    required TimeOfDay time,
  }) async {
    try {
      await _channel.invokeMethod('scheduleDailyNotification', {
        'hour': time.hour,
        'minute': time.minute,
      });
    } catch (e) {
      Logger.warning('Failed to schedule notification: $e');
    }
  }

  static Future<void> showFortuneNotification({
    required Fortune fortune,
  }) async {
    try {
      await _channel.invokeMethod('showFortuneNotification', {
        'score': fortune.score,
        'message': fortune.message,
        'luckyNumbers': fortune.luckyNumbers,
      });
    } catch (e) {
      Logger.warning('Failed to show notification: $e');
    }
  }
}
```

### Best Practices

**Channel Management**:
- Create distinct channels for different notification types
- Allow users to customize each channel
- Respect system notification settings
- Use appropriate importance levels

**Content Design**:
- Provide expandable rich content
- Include actionable buttons
- Use large icons for visibility
- Support both light and dark themes

**Timing**:
- Respect user's preferred notification times
- Don't spam with too many notifications
- Use WorkManager for reliable scheduling
- Handle timezone changes properly

---

## Platform Channel Integration

Bidirectional communication between Flutter and native code.

### iOS Platform Channel Setup

```swift
// AppDelegate.swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        setupPlatformChannels()
        setupLiveActivities()
        setupWatchConnectivity()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupPlatformChannels() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        // Native Features Channel
        let nativeFeaturesChannel = FlutterMethodChannel(
            name: "com.fortune.ios/native_features",
            binaryMessenger: controller.binaryMessenger
        )

        nativeFeaturesChannel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "updateWidget":
                self?.handleUpdateWidget(call: call, result: result)
            case "startLiveActivity":
                self?.handleStartLiveActivity(call: call, result: result)
            case "sendToWatch":
                self?.handleSendToWatch(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func handleUpdateWidget(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let score = args["fortuneScore"] as? Int,
              let message = args["message"] as? String,
              let numbers = args["luckyNumbers"] as? [Int] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        Task {
            await WidgetService.shared.updateWidget(
                score: score,
                message: message,
                luckyNumbers: numbers
            )
            result(nil)
        }
    }
}
```

### Android Platform Channel Setup

```kotlin
// MainActivity.kt
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var nativeFeaturesChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        setupPlatformChannels(flutterEngine)
    }

    private fun setupPlatformChannels(flutterEngine: FlutterEngine) {
        nativeFeaturesChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.fortune.android/native_features"
        )

        nativeFeaturesChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> handleUpdateWidget(call, result)
                "getDynamicColors" -> handleGetDynamicColors(call, result)
                "scheduleNotification" -> handleScheduleNotification(call, result)
                "sendToWear" -> handleSendToWear(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleUpdateWidget(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<String, Any> ?: run {
            result.error("INVALID_ARGS", "Invalid arguments", null)
            return
        }

        val widgetId = args["widgetId"] as? Int
        val fortuneData = args["fortuneData"] as? Map<String, Any>

        lifecycleScope.launch {
            try {
                WidgetService.updateWidget(applicationContext, widgetId, fortuneData)
                result.success(null)
            } catch (e: Exception) {
                result.error("UPDATE_FAILED", e.message, null)
            }
        }
    }
}
```

### Flutter Service Layer

```dart
// lib/services/native_features_service.dart
class NativeFeaturesService {
  static final NativeFeaturesService _instance = NativeFeaturesService._internal();
  factory NativeFeaturesService() => _instance;
  NativeFeaturesService._internal();

  late final MethodChannel _iosChannel;
  late final MethodChannel _androidChannel;

  void initialize() {
    if (Platform.isIOS) {
      _iosChannel = const MethodChannel('com.fortune.ios/native_features');
    } else if (Platform.isAndroid) {
      _androidChannel = const MethodChannel('com.fortune.android/native_features');
    }
  }

  Future<void> updateWidgets(Fortune fortune) async {
    try {
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('updateWidget', {
          'fortuneScore': fortune.score,
          'message': fortune.message,
          'luckyNumbers': fortune.luckyNumbers,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else if (Platform.isAndroid) {
        await _androidChannel.invokeMethod('updateWidget', {
          'widgetId': null, // Update all widgets
          'fortuneData': {
            'score': fortune.score,
            'message': fortune.message,
            'luckyNumbers': fortune.luckyNumbers,
          },
        });
      }
    } catch (e) {
      Logger.warning('Failed to update widgets: $e');
    }
  }

  Future<void> startLiveActivity(String userName, int score) async {
    if (!Platform.isIOS) return;

    try {
      await _iosChannel.invokeMethod('startLiveActivity', {
        'userName': userName,
        'initialScore': score,
      });
    } catch (e) {
      Logger.warning('Failed to start live activity: $e');
    }
  }

  Future<Map<String, int>?> getDynamicColors() async {
    if (!Platform.isAndroid) return null;

    try {
      final result = await _androidChannel.invokeMethod('getDynamicColors');
      return Map<String, int>.from(result as Map);
    } catch (e) {
      Logger.warning('Failed to get dynamic colors: $e');
      return null;
    }
  }
}
```

### Best Practices

**Error Handling**:
- Always wrap platform channel calls in try-catch
- Provide meaningful error messages
- Implement fallback behavior
- Log errors for debugging

**Data Serialization**:
- Use simple data types (int, String, Map, List)
- Avoid complex nested structures
- Validate data on both sides
- Handle null values properly

**Performance**:
- Don't block the UI thread
- Use async operations for heavy work
- Batch multiple calls when possible
- Cache results when appropriate

**Testing**:
- Mock platform channels in unit tests
- Test error scenarios
- Verify data serialization
- Test on real devices

---

## Common Patterns & Best Practices

### Project Structure

```
fortune/
├── lib/
│   └── services/
│       ├── native_features_service.dart
│       ├── widget_service.dart
│       ├── notification_service.dart
│       └── wearable_service.dart
├── ios/
│   ├── Runner/
│   ├── FortuneWidgetExtension/
│   │   ├── FortuneWidget.swift
│   │   ├── FortuneWidgetProvider.swift
│   │   └── Views/
│   ├── FortuneLiveActivity/
│   │   └── FortuneLiveActivity.swift
│   ├── FortuneWatchApp/
│   │   ├── FortuneApp.swift
│   │   └── Views/
│   └── Shared/
│       ├── Models/
│       ├── Services/
│       └── Resources/
└── android/
    ├── app/
    │   └── src/main/
    │       ├── kotlin/com/fortune/
    │       │   ├── MainActivity.kt
    │       │   ├── widgets/
    │       │   ├── services/
    │       │   └── receivers/
    │       └── res/
    │           ├── layout/
    │           └── xml/
    └── wear/
        └── src/main/
```

### Data Sharing Strategy

#### iOS App Groups

```swift
// Shared container for data
let sharedDefaults = UserDefaults(suiteName: "group.com.fortune.shared")!

// Save data
sharedDefaults.set(fortuneScore, forKey: "daily_score")
sharedDefaults.set(fortuneMessage, forKey: "daily_message")

// Read data
let score = sharedDefaults.integer(forKey: "daily_score")
let message = sharedDefaults.string(forKey: "daily_message")
```

#### Android Shared Preferences

```kotlin
// Write data
val prefs = context.getSharedPreferences("fortune_data", Context.MODE_PRIVATE)
prefs.edit {
    putInt("daily_score", fortuneScore)
    putString("daily_message", fortuneMessage)
}

// Read data
val score = prefs.getInt("daily_score", 0)
val message = prefs.getString("daily_message", "")
```

### Update Strategies

**Timeline-Based (iOS)**:
```swift
// Update at specific times
let entries: [FortuneEntry] = [
    FortuneEntry(date: midnight, fortune: todayFortune),
    FortuneEntry(date: tomorrow, fortune: tomorrowFortune)
]

let timeline = Timeline(entries: entries, policy: .atEnd)
```

**Periodic Updates (Android)**:
```kotlin
// Update every hour
val updateRequest = PeriodicWorkRequestBuilder<FortuneUpdateWorker>(
    1, TimeUnit.HOURS
).build()

WorkManager.getInstance(context).enqueue(updateRequest)
```

### Battery Optimization

**iOS**:
- Use `.atEnd` timeline policy for widgets
- Minimize background refresh
- Use efficient image formats
- Cache computed data

**Android**:
- Use WorkManager constraints
- Respect Doze mode
- Batch network requests
- Use efficient layouts (Glance)

### Testing Checklist

**Widgets**:
- [ ] Test all widget sizes
- [ ] Verify timeline updates
- [ ] Check configuration flow
- [ ] Test widget removal
- [ ] Verify deep linking

**Wearables**:
- [ ] Test on physical devices
- [ ] Verify data synchronization
- [ ] Check complication updates
- [ ] Test battery impact
- [ ] Verify connectivity scenarios

**Notifications**:
- [ ] Test all notification channels
- [ ] Verify actions work correctly
- [ ] Check notification grouping
- [ ] Test scheduling reliability
- [ ] Verify permission handling

**Platform Channels**:
- [ ] Test error scenarios
- [ ] Verify data serialization
- [ ] Check null handling
- [ ] Test on various OS versions
- [ ] Verify memory leaks

### Performance Metrics

**Target Metrics**:
- Widget load time: < 500ms
- Background update: < 2s
- Battery impact: < 2% per day
- Memory usage: < 50MB
- Network efficiency: < 1MB per day

### Deployment Checklist

**iOS**:
- [ ] Configure App Groups
- [ ] Add widget extension targets
- [ ] Update Info.plist files
- [ ] Configure background modes
- [ ] Test on TestFlight

**Android**:
- [ ] Add widget receivers to manifest
- [ ] Create notification channels
- [ ] Configure WorkManager
- [ ] Test on internal track
- [ ] Verify Wear OS module

### Troubleshooting Guide

**Widget Not Updating**:
1. Check App Group configuration
2. Verify timeline policy
3. Check background refresh settings
4. Review system logs
5. Test with fresh install

**Live Activity Not Starting**:
1. Verify Info.plist configuration
2. Check user permissions
3. Ensure proper initialization
4. Test push notification setup
5. Review ActivityKit logs

**Wear OS Connection Issues**:
1. Verify both apps installed
2. Check Bluetooth connection
3. Test data layer API
4. Review manifest permissions
5. Check Play Services version

---

## Summary

This consolidated guide provides a complete reference for implementing native platform features in the Fortune Flutter app. Each section is organized by feature rather than platform, making it easy to find implementation details for both iOS and Android in one place.

### Key Takeaways

1. **Feature-First Approach**: Understand what you want to implement, then find the platform-specific details
2. **Graceful Degradation**: Always handle unsupported platforms and older OS versions
3. **Consistent Experience**: Maintain Fortune branding across all native features
4. **Performance First**: Optimize for battery life and responsiveness
5. **User Privacy**: Respect permissions and handle sensitive data carefully

### Next Steps

1. Choose features based on priority and user value
2. Set up development environment for native code
3. Implement platform channels for Flutter integration
4. Test thoroughly on real devices
5. Monitor performance metrics in production
6. Iterate based on user feedback

For platform-specific implementation details, refer to the code examples throughout this guide.