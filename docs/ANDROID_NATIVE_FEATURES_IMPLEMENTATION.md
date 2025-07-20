# Android Native Features Implementation Guide

## 🤖 Overview

Fortune 앱의 Android 네이티브 기능 구현을 위한 상세 가이드입니다.

## 📦 Dependencies & Setup

### build.gradle (app level)
```gradle
dependencies {
    // 기존 의존성...
    
    // Android Widgets
    implementation 'androidx.glance:glance-appwidget:1.0.0'
    implementation 'androidx.glance:glance-material3:1.0.0'
    
    // Material You
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.compose.material3:material3:1.2.0'
    implementation 'androidx.compose.material3:material3-window-size-class:1.2.0'
    
    // Wear OS
    implementation 'androidx.wear:wear:1.3.0'
    implementation 'androidx.wear.compose:compose-material:1.3.0'
    implementation 'androidx.wear.compose:compose-foundation:1.3.0'
    
    // Work Manager for background updates
    implementation 'androidx.work:work-runtime-ktx:2.9.0'
}
```

### AndroidManifest.xml
```xml
<manifest>
    <!-- Widget Provider -->
    <receiver android:name=".widgets.FortuneWidgetProvider"
        android:exported="true">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        </intent-filter>
        <meta-data
            android:name="android.appwidget.provider"
            android:resource="@xml/fortune_widget_info" />
    </receiver>
    
    <!-- Widget Configuration Activity -->
    <activity android:name=".widgets.FortuneWidgetConfigActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_CONFIGURE" />
        </intent-filter>
    </activity>
    
    <!-- Material You Dynamic Color -->
    <application
        android:theme="@style/Theme.Fortune.DynamicColors">
    </application>
</manifest>
```

## 1️⃣ Home Screen Widgets with Glance

### Widget Definition
```kotlin
// FortuneWidget.kt
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class FortuneWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            FortuneWidgetContent()
        }
    }
}

class FortuneWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = FortuneWidget()
}
```

### Widget UI with Compose
```kotlin
// FortuneWidgetContent.kt
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.*
import androidx.glance.layout.*
import androidx.glance.text.Text
import androidx.glance.appwidget.cornerRadius

@Composable
fun FortuneWidgetContent() {
    val prefs = currentState<Preferences>()
    val fortuneData = prefs[fortuneDataKey] ?: FortuneData.default()
    
    GlanceTheme {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(GlanceTheme.colors.primaryContainer)
                .cornerRadius(16.dp)
                .clickable(
                    onClick = actionStartActivity<MainActivity>(
                        parameters = actionParametersOf(
                            "fortune_type" to fortuneData.type
                        )
                    )
                )
        ) {
            when (LocalSize.current) {
                SizeMode.Small -> SmallFortuneWidget(fortuneData)
                SizeMode.Medium -> MediumFortuneWidget(fortuneData)
                SizeMode.Large -> LargeFortuneWidget(fortuneData)
            }
        }
    }
}

@Composable
fun SmallFortuneWidget(data: FortuneData) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 운세 점수
        CircularProgressIndicator(
            progress = data.score / 100f,
            modifier = GlanceModifier.size(48.dp),
            color = ColorProvider(data.luckyColor)
        )
        
        Spacer(modifier = GlanceModifier.height(8.dp))
        
        Text(
            text = "${data.score}%",
            style = TextStyle(
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                color = GlanceTheme.colors.onPrimaryContainer
            )
        )
        
        Text(
            text = data.shortMessage,
            style = TextStyle(
                fontSize = 12.sp,
                color = GlanceTheme.colors.onPrimaryContainer
            ),
            maxLines = 2
        )
    }
}

@Composable
fun MediumFortuneWidget(data: FortuneData) {
    Row(
        modifier = GlanceModifier
            .fillMaxSize()
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 타로 카드 이미지
        Image(
            provider = ImageProvider(R.drawable.tarot_back),
            contentDescription = "Tarot Card",
            modifier = GlanceModifier
                .size(80.dp)
                .clickable(
                    onClick = actionRunCallback<TarotFlipAction>()
                )
        )
        
        Spacer(modifier = GlanceModifier.width(16.dp))
        
        Column(
            modifier = GlanceModifier.fillMaxWidth()
        ) {
            Text(
                text = "오늘의 운세",
                style = TextStyle(
                    fontSize = 14.sp,
                    color = GlanceTheme.colors.secondary
                )
            )
            
            Text(
                text = data.message,
                style = TextStyle(
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = GlanceTheme.colors.onPrimaryContainer
                ),
                maxLines = 2
            )
            
            Spacer(modifier = GlanceModifier.height(8.dp))
            
            Row {
                LuckyInfoChip(
                    icon = R.drawable.ic_color,
                    value = data.luckyColor,
                    color = ColorProvider(data.luckyColor)
                )
                
                Spacer(modifier = GlanceModifier.width(8.dp))
                
                LuckyInfoChip(
                    icon = R.drawable.ic_number,
                    value = data.luckyNumber.toString()
                )
            }
        }
    }
}
```

### Interactive Widget Actions
```kotlin
// TarotFlipAction.kt
import androidx.glance.action.ActionCallback
import androidx.glance.appwidget.action.ActionCallbackWorker

class TarotFlipAction : ActionCallback {
    override suspend fun onRun(context: Context, glanceId: GlanceId) {
        // 타로 카드 뒤집기 애니메이션
        val prefs = GlancePreferencesManager.getPreferences(context, glanceId)
        val isFlipped = prefs[isFlippedKey] ?: false
        
        GlancePreferencesManager.updatePreferences(context, glanceId) {
            it[isFlippedKey] = !isFlipped
            if (!isFlipped) {
                // 새로운 타로 카드 데이터 가져오기
                val newCard = TarotService.drawDailyCard()
                it[tarotCardKey] = newCard.toJson()
            }
        }
        
        FortuneWidget().update(context, glanceId)
    }
}

class TarotFlipWorker(
    context: Context,
    params: WorkerParameters
) : ActionCallbackWorker(context, params, TarotFlipAction::class.java)
```

### Widget Update Worker
```kotlin
// FortuneWidgetUpdateWorker.kt
import androidx.work.*
import java.util.concurrent.TimeUnit

class FortuneWidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // 운세 데이터 업데이트
            val fortuneData = FortuneRepository.getDailyFortune()
            
            // 모든 위젯 업데이트
            GlanceAppWidgetManager(applicationContext)
                .getGlanceIds(FortuneWidget::class.java)
                .forEach { glanceId ->
                    updateAppWidgetState(applicationContext, glanceId) { prefs ->
                        prefs[fortuneDataKey] = fortuneData.toJson()
                    }
                    FortuneWidget().update(applicationContext, glanceId)
                }
            
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }
    
    companion object {
        fun enqueue(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()
            
            val updateRequest = PeriodicWorkRequestBuilder<FortuneWidgetUpdateWorker>(
                6, TimeUnit.HOURS
            )
                .setConstraints(constraints)
                .build()
            
            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "fortune_widget_update",
                    ExistingPeriodicWorkPolicy.REPLACE,
                    updateRequest
                )
        }
    }
}
```

## 2️⃣ Material You Dynamic Theming

### Dynamic Color Setup
```kotlin
// MainActivity.kt
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import com.google.android.material.color.DynamicColors

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Material You 다이나믹 컬러 적용
        DynamicColors.applyToActivityIfAvailable(this)
    }
}
```

### Compose Theme with Dynamic Colors
```kotlin
// FortuneTheme.kt
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

@Composable
fun FortuneTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) 
            else dynamicLightColorScheme(context)
        }
        darkTheme -> darkColorScheme()
        else -> lightColorScheme()
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = FortuneTypography,
        content = content
    )
}
```

### Flutter Integration for Dynamic Colors
```dart
// android_theme_service.dart
import 'package:dynamic_color/dynamic_color.dart';

class AndroidThemeService {
  static Future<ColorScheme?> getDynamicColorScheme() async {
    return DynamicColorPlugin.getCorePalette().then((corePalette) {
      if (corePalette != null) {
        return corePalette.toColorScheme();
      }
      return null;
    });
  }
  
  static StreamController<ColorScheme> _themeController = 
    StreamController<ColorScheme>.broadcast();
  
  static Stream<ColorScheme> get themeStream => _themeController.stream;
  
  static void init() {
    if (Platform.isAndroid) {
      // 배경화면 변경 감지
      SystemChannels.lifecycle.setMessageHandler((msg) {
        if (msg == AppLifecycleState.resumed.toString()) {
          _updateTheme();
        }
        return Future.value();
      });
    }
  }
  
  static Future<void> _updateTheme() async {
    final colorScheme = await getDynamicColorScheme();
    if (colorScheme != null) {
      _themeController.add(colorScheme);
    }
  }
}
```

## 3️⃣ Notification Channels

### Notification Channel Setup
```kotlin
// NotificationChannelManager.kt
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager

object NotificationChannelManager {
    const val GROUP_FORTUNE = "fortune_group"
    const val CHANNEL_DAILY = "daily_fortune"
    const val CHANNEL_WEEKLY = "weekly_fortune"
    const val CHANNEL_SPECIAL = "special_events"
    const val CHANNEL_LUCKY_TIME = "lucky_time"
    
    fun createChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            
            // 그룹 생성
            val fortuneGroup = NotificationChannelGroup(
                GROUP_FORTUNE,
                "운세 알림"
            )
            notificationManager.createNotificationChannelGroup(fortuneGroup)
            
            // 일일 운세 채널
            val dailyChannel = NotificationChannel(
                CHANNEL_DAILY,
                "오늘의 운세",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "매일 아침 오늘의 운세를 알려드립니다"
                group = GROUP_FORTUNE
                setShowBadge(true)
                enableLights(true)
                lightColor = Color.YELLOW
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
            }
            
            // 주간 운세 채널
            val weeklyChannel = NotificationChannel(
                CHANNEL_WEEKLY,
                "주간 운세",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "매주 월요일 주간 운세를 알려드립니다"
                group = GROUP_FORTUNE
                setShowBadge(false)
            }
            
            // 특별 이벤트 채널
            val specialChannel = NotificationChannel(
                CHANNEL_SPECIAL,
                "특별한 날",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "보름달, 신월 등 특별한 날의 운세"
                group = GROUP_FORTUNE
                setShowBadge(true)
                enableLights(true)
                lightColor = Color.MAGENTA
            }
            
            // 행운의 시간 채널
            val luckyTimeChannel = NotificationChannel(
                CHANNEL_LUCKY_TIME,
                "행운의 시간",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "오늘의 행운 시간대를 알려드립니다"
                group = GROUP_FORTUNE
                setShowBadge(false)
                enableVibration(false)
            }
            
            notificationManager.createNotificationChannels(
                listOf(dailyChannel, weeklyChannel, specialChannel, luckyTimeChannel)
            )
        }
    }
}
```

### Rich Notifications
```kotlin
// FortuneNotificationBuilder.kt
import androidx.core.app.NotificationCompat
import androidx.core.graphics.drawable.IconCompat

class FortuneNotificationBuilder(private val context: Context) {
    
    fun buildDailyFortuneNotification(fortuneData: FortuneData): Notification {
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                putExtra("open_fortune", true)
            },
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(context, CHANNEL_DAILY)
            .setSmallIcon(R.drawable.ic_fortune_small)
            .setLargeIcon(
                IconCompat.createWithResource(context, R.drawable.ic_fortune_large)
                    .toIcon(context)
            )
            .setContentTitle("오늘의 운세 ${fortuneData.score}점")
            .setContentText(fortuneData.message)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(fortuneData.detailedMessage)
                    .setBigContentTitle("${fortuneData.userName}님의 오늘 운세")
                    .setSummaryText("행운의 색: ${fortuneData.luckyColor}")
            )
            .setColor(Color.parseColor(fortuneData.luckyColor))
            .addAction(
                R.drawable.ic_tarot,
                "타로 카드 뽑기",
                createTarotPendingIntent()
            )
            .addAction(
                R.drawable.ic_share,
                "공유하기",
                createSharePendingIntent(fortuneData)
            )
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_RECOMMENDATION)
            .build()
    }
    
    fun buildLuckyTimeNotification(luckyTime: LuckyTime): Notification {
        return NotificationCompat.Builder(context, CHANNEL_LUCKY_TIME)
            .setSmallIcon(R.drawable.ic_clock)
            .setContentTitle("🍀 지금이 행운의 시간!")
            .setContentText("${luckyTime.startTime} - ${luckyTime.endTime}")
            .setStyle(
                NotificationCompat.InboxStyle()
                    .addLine("💰 금전운: ${luckyTime.moneyLuck}")
                    .addLine("❤️ 연애운: ${luckyTime.loveLuck}")
                    .addLine("💼 직장운: ${luckyTime.workLuck}")
                    .setSummaryText("행운 지수: ${luckyTime.totalScore}%")
            )
            .setTimeoutAfter(luckyTime.duration)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .build()
    }
}
```

## 4️⃣ Wear OS App

### Wear OS App Structure
```
wear/
├── src/main/
│   ├── java/com/fortune/wear/
│   │   ├── FortuneWearApp.kt
│   │   ├── presentation/
│   │   │   ├── MainActivity.kt
│   │   │   ├── FortuneScreen.kt
│   │   │   └── TileService.kt
│   │   └── complications/
│   │       └── FortuneComplicationService.kt
│   └── res/
```

### Wear OS Main Activity
```kotlin
// MainActivity.kt (Wear)
import androidx.wear.compose.material.*
import androidx.wear.compose.navigation.SwipeDismissableNavHost

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
    WearAppTheme {
        val navController = rememberSwipeDismissableNavController()
        
        SwipeDismissableNavHost(
            navController = navController,
            startDestination = "home"
        ) {
            composable("home") {
                FortuneHomeScreen(
                    onNavigateToDetail = { 
                        navController.navigate("detail")
                    }
                )
            }
            
            composable("detail") {
                FortuneDetailScreen()
            }
        }
    }
}
```

### Wear OS Fortune Screen
```kotlin
// FortuneScreen.kt
@Composable
fun FortuneHomeScreen(
    onNavigateToDetail: () -> Unit
) {
    val scrollState = rememberScalingLazyListState()
    val fortuneData by remember { mutableStateOf(FortuneRepository.getTodaysFortune()) }
    
    Scaffold(
        timeText = {
            TimeText(
                modifier = Modifier.scrollAway(scrollState)
            )
        },
        vignette = {
            Vignette(vignettePosition = VignettePosition.TopAndBottom)
        }
    ) {
        ScalingLazyColumn(
            modifier = Modifier.fillMaxSize(),
            state = scrollState,
            autoCentering = AutoCenteringParams(itemIndex = 0)
        ) {
            item {
                FortuneCard(
                    fortuneData = fortuneData,
                    onClick = onNavigateToDetail
                )
            }
            
            item {
                LuckyInfoRow(
                    luckyColor = fortuneData.luckyColor,
                    luckyNumber = fortuneData.luckyNumber
                )
            }
            
            item {
                Chip(
                    label = { Text("타로 카드 뽑기") },
                    onClick = { /* Handle tarot */ },
                    icon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_tarot),
                            contentDescription = null
                        )
                    }
                )
            }
            
            item {
                CompactChip(
                    label = { Text("운세 공유") },
                    onClick = { /* Handle share */ }
                )
            }
        }
    }
}
```

### Wear OS Tile Service
```kotlin
// FortuneTileService.kt
import androidx.wear.tiles.*

class FortuneTileService : TileService() {
    override suspend fun onTileRequest(
        requestParams: TileRequest
    ): Tile {
        val fortuneData = FortuneRepository.getQuickFortune()
        
        return Tile.Builder()
            .setResourcesVersion(RESOURCES_VERSION)
            .setTimeline(
                Timeline.Builder()
                    .addTimelineEntry(
                        TimelineEntry.Builder()
                            .setLayout(createLayout(fortuneData))
                            .build()
                    )
                    .build()
            )
            .build()
    }
    
    private fun createLayout(data: FortuneData): Layout {
        return Layout.Builder()
            .setRoot(
                Column.Builder()
                    .addContent(
                        Text.Builder()
                            .setText("오늘의 운세")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(DimensionBuilders.sp(14f))
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        CircularProgressIndicator.Builder()
                            .setProgress(data.score / 100f)
                            .setCircularProgressIndicatorColors(
                                ProgressIndicatorColors(
                                    ColorBuilders.argb(data.luckyColorArgb),
                                    ColorBuilders.argb(0x80FFFFFF)
                                )
                            )
                            .build()
                    )
                    .addContent(
                        Text.Builder()
                            .setText("${data.score}%")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(DimensionBuilders.sp(20f))
                                    .setWeight(FONT_WEIGHT_BOLD)
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
    }
}
```

## 5️⃣ Flutter Platform Integration

### Method Channel Setup
```dart
// android_native_service.dart
class AndroidNativeService {
  static const _channel = MethodChannel('com.fortune.fortune/android');
  
  // 위젯 업데이트
  Future<void> updateWidget(FortuneData data) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'fortuneScore': data.score,
        'message': data.message,
        'luckyColor': data.luckyColor,
        'luckyNumber': data.luckyNumber,
        'shortMessage': data.shortMessage,
      });
    } catch (e) {
      Logger.error('Failed to update widget', e);
    }
  }
  
  // Material You 색상 가져오기
  Future<Map<String, int>?> getDynamicColors() async {
    try {
      final result = await _channel.invokeMethod('getDynamicColors');
      return Map<String, int>.from(result);
    } catch (e) {
      Logger.error('Failed to get dynamic colors', e);
      return null;
    }
  }
  
  // 알림 채널 설정
  Future<void> setupNotificationChannels() async {
    try {
      await _channel.invokeMethod('setupNotificationChannels');
    } catch (e) {
      Logger.error('Failed to setup notification channels', e);
    }
  }
  
  // 알림 예약
  Future<void> scheduleNotification({
    required String channel,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'channel': channel,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'payload': payload,
      });
    } catch (e) {
      Logger.error('Failed to schedule notification', e);
    }
  }
}
```

### Native Kotlin Handler
```kotlin
// MainActivity.kt
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fortune.fortune/android"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        updateWidget(call.arguments as Map<String, Any>)
                        result.success(null)
                    }
                    "getDynamicColors" -> {
                        result.success(getDynamicColors())
                    }
                    "setupNotificationChannels" -> {
                        NotificationChannelManager.createChannels(this)
                        result.success(null)
                    }
                    "scheduleNotification" -> {
                        scheduleNotification(call.arguments as Map<String, Any>)
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    private fun updateWidget(data: Map<String, Any>) {
        val prefs = getSharedPreferences("widget_data", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putInt("fortuneScore", data["fortuneScore"] as Int)
            putString("message", data["message"] as String)
            putString("luckyColor", data["luckyColor"] as String)
            putInt("luckyNumber", data["luckyNumber"] as Int)
            putString("shortMessage", data["shortMessage"] as String)
            apply()
        }
        
        // 위젯 업데이트 트리거
        val intent = Intent(this, FortuneWidgetReceiver::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        sendBroadcast(intent)
    }
    
    private fun getDynamicColors(): Map<String, Int>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val colors = resources
            mapOf(
                "primary" to colors.getColor(android.R.color.system_accent1_500, theme),
                "secondary" to colors.getColor(android.R.color.system_accent2_500, theme),
                "tertiary" to colors.getColor(android.R.color.system_accent3_500, theme),
                "surface" to colors.getColor(android.R.color.system_neutral1_500, theme)
            )
        } else {
            null
        }
    }
}
```

## 🧪 Testing

### Widget Testing
```kotlin
// FortuneWidgetTest.kt
@RunWith(AndroidJUnit4::class)
class FortuneWidgetTest {
    @Test
    fun testWidgetUpdate() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val glanceId = GlanceAppWidgetManager(context)
            .getGlanceIds(FortuneWidget::class.java)
            .first()
        
        runBlocking {
            updateAppWidgetState(context, glanceId) { prefs ->
                prefs[fortuneDataKey] = FortuneData(
                    score = 85,
                    message = "Test Fortune",
                    luckyColor = "#FF6B6B"
                ).toJson()
            }
            
            FortuneWidget().update(context, glanceId)
        }
        
        // Verify widget updated
    }
}
```

### Notification Channel Testing
```bash
# ADB로 알림 채널 확인
adb shell cmd notification list-channels com.fortune.fortune

# 테스트 알림 발송
adb shell cmd notification post -t "테스트" -c daily_fortune com.fortune.fortune
```

## 📋 Deployment Checklist

1. **Widget 설정**
   - `res/xml/fortune_widget_info.xml` 생성
   - Widget preview 이미지 추가
   - 다양한 크기 지원 설정

2. **Material You**
   - `themes.xml`에 Dynamic Colors 설정
   - API 31+ 대응 처리

3. **Wear OS**
   - Wear 모듈 추가
   - Standalone 앱 설정
   - Play Store 별도 등록

4. **권한 설정**
   - POST_NOTIFICATIONS (API 33+)
   - SCHEDULE_EXACT_ALARM
   - VIBRATE

5. **Play Store 준비**
   - Widget 스크린샷
   - Wear OS 스크린샷
   - 기능 그래픽 준비

이 가이드를 따라 Android 네이티브 기능을 구현하면, Fortune 앱이 Android 사용자의 홈 화면과 일상에 완벽하게 통합됩니다.