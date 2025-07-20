# Android Native Features Implementation Guide

## Table of Contents

1. [Project Setup](#project-setup)
2. [Home Screen Widgets](#home-screen-widgets)
3. [Material You Dynamic Theming](#material-you-dynamic-theming)
4. [Advanced Notification Channels](#advanced-notification-channels)
5. [Wear OS Integration](#wear-os-integration)
6. [Implementation Examples](#implementation-examples)
7. [Best Practices](#best-practices)

## Project Setup

### 1. Update Android Project Structure

```
android/
├── app/
│   ├── src/main/
│   │   ├── java/com/fortune/
│   │   │   ├── MainActivity.kt
│   │   │   ├── widgets/
│   │   │   │   ├── FortuneWidgetProvider.kt
│   │   │   │   ├── FortuneWidgetService.kt
│   │   │   │   └── FortuneWidgetConfigActivity.kt
│   │   │   ├── services/
│   │   │   │   ├── FortuneUpdateService.kt
│   │   │   │   └── NotificationService.kt
│   │   │   └── receivers/
│   │   │       └── FortuneWidgetReceiver.kt
│   │   └── res/
│   │       ├── layout/
│   │       │   ├── widget_fortune_small.xml
│   │       │   ├── widget_fortune_medium.xml
│   │       │   └── widget_fortune_large.xml
│   │       └── xml/
│   │           └── fortune_widget_info.xml
│   └── build.gradle
└── wear/
    ├── src/main/
    └── build.gradle
```

### 2. Update Dependencies

In `app/build.gradle`:

```gradle
dependencies {
    implementation "androidx.glance:glance-appwidget:1.0.0"
    implementation "androidx.glance:glance-material3:1.0.0"
    implementation "androidx.work:work-runtime-ktx:2.9.0"
    implementation "androidx.datastore:datastore-preferences:1.0.0"
    
    // Material You
    implementation "com.google.android.material:material:1.11.0"
    implementation "androidx.palette:palette-ktx:1.0.0"
    
    // Wear OS
    implementation "androidx.wear:wear:1.3.0"
    implementation "androidx.wear.compose:compose-material:1.3.0"
    implementation "androidx.wear.compose:compose-foundation:1.3.0"
    
    // Notifications
    implementation "androidx.core:core-ktx:1.12.0"
}
```

### 3. Update AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application>
        <!-- Widget Receiver -->
        <receiver 
            android:name=".widgets.FortuneWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/fortune_widget_info" />
        </receiver>
        
        <!-- Widget Configuration Activity -->
        <activity
            android:name=".widgets.FortuneWidgetConfigActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_CONFIGURE" />
            </intent-filter>
        </activity>
        
        <!-- Update Service -->
        <service
            android:name=".services.FortuneUpdateService"
            android:permission="android.permission.BIND_JOB_SERVICE" />
        
        <!-- Boot Receiver -->
        <receiver
            android:name=".receivers.BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

## Home Screen Widgets

### 1. Widget Provider Implementation

Create `FortuneWidgetProvider.kt`:

```kotlin
package com.fortune.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.work.*
import com.fortune.R
import java.util.concurrent.TimeUnit

class FortuneWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = FortuneGlanceWidget()
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        
        // Schedule periodic updates
        scheduleWidgetUpdates(context)
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleWidgetUpdates(context)
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        WorkManager.getInstance(context).cancelAllWorkByTag(WIDGET_UPDATE_TAG)
    }
    
    private fun scheduleWidgetUpdates(context: Context) {
        val updateRequest = PeriodicWorkRequestBuilder<FortuneUpdateWorker>(
            1, TimeUnit.HOURS
        )
            .addTag(WIDGET_UPDATE_TAG)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()
        
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WIDGET_UPDATE_WORK_NAME,
            ExistingPeriodicWorkPolicy.REPLACE,
            updateRequest
        )
    }
    
    companion object {
        const val WIDGET_UPDATE_TAG = "fortune_widget_update"
        const val WIDGET_UPDATE_WORK_NAME = "fortune_widget_periodic_update"
    }
}
```

### 2. Glance Widget Implementation

Create `FortuneGlanceWidget.kt`:

```kotlin
package com.fortune.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

class FortuneGlanceWidget : GlanceAppWidget() {
    
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            FortuneWidgetContent()
        }
    }
    
    @Composable
    fun FortuneWidgetContent() {
        val fortuneData = currentState<FortuneData>() ?: FortuneData.default()
        
        GlanceTheme {
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(ImageProvider(R.drawable.widget_background))
                    .clickable(actionRunCallback<OpenAppAction>())
                    .padding(16.dp)
            ) {
                when (LocalSize.current) {
                    is SmallSize -> SmallFortuneWidget(fortuneData)
                    is MediumSize -> MediumFortuneWidget(fortuneData)
                    is LargeSize -> LargeFortuneWidget(fortuneData)
                    else -> SmallFortuneWidget(fortuneData)
                }
            }
        }
    }
    
    @Composable
    fun SmallFortuneWidget(fortune: FortuneData) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(
                provider = ImageProvider(R.drawable.ic_fortune),
                contentDescription = "Fortune Icon",
                modifier = GlanceModifier.size(32.dp)
            )
            
            Text(
                text = "${fortune.score}/100",
                style = TextStyle(
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(fortune.getScoreColor())
                )
            )
            
            Text(
                text = "Today",
                style = TextStyle(
                    fontSize = 12.sp,
                    color = ColorProvider(R.color.text_secondary)
                )
            )
        }
    }
    
    @Composable
    fun MediumFortuneWidget(fortune: FortuneData) {
        Row(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Score Section
            Column(
                modifier = GlanceModifier.defaultWeight(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "${fortune.score}",
                    style = TextStyle(
                        fontSize = 36.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(fortune.getScoreColor())
                    )
                )
                Text(
                    text = "Fortune Score",
                    style = TextStyle(fontSize = 12.sp)
                )
            }
            
            // Divider
            Box(
                modifier = GlanceModifier
                    .width(1.dp)
                    .fillMaxHeight()
                    .background(ColorProvider(R.color.divider))
            )
            
            // Lucky Numbers Section
            Column(
                modifier = GlanceModifier.defaultWeight(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Lucky Numbers",
                    style = TextStyle(fontSize = 12.sp)
                )
                Row(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = GlanceModifier.padding(top = 8.dp)
                ) {
                    fortune.luckyNumbers.forEach { number ->
                        Box(
                            modifier = GlanceModifier
                                .padding(horizontal = 4.dp)
                                .background(
                                    ColorProvider(R.color.lucky_number_bg),
                                    cornerRadius = 12.dp
                                )
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(
                                text = number.toString(),
                                style = TextStyle(
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            )
                        }
                    }
                }
            }
        }
    }
    
    @Composable
    fun LargeFortuneWidget(fortune: FortuneData) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Header
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    provider = ImageProvider(R.drawable.ic_fortune),
                    contentDescription = null,
                    modifier = GlanceModifier.size(48.dp)
                )
                
                Column(
                    modifier = GlanceModifier
                        .defaultWeight()
                        .padding(horizontal = 12.dp)
                ) {
                    Text(
                        text = "Today's Fortune",
                        style = TextStyle(
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Text(
                        text = fortune.date,
                        style = TextStyle(
                            fontSize = 12.sp,
                            color = ColorProvider(R.color.text_secondary)
                        )
                    )
                }
                
                Text(
                    text = "${fortune.score}/100",
                    style = TextStyle(
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(fortune.getScoreColor())
                    )
                )
            }
            
            // Message
            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .padding(vertical = 12.dp)
                    .background(
                        ColorProvider(R.color.message_bg),
                        cornerRadius = 8.dp
                    )
                    .padding(12.dp)
            ) {
                Text(
                    text = fortune.message,
                    style = TextStyle(fontSize = 14.sp),
                    maxLines = 3
                )
            }
            
            // Bottom Section
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.SpaceBetween
            ) {
                // Lucky Color
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = GlanceModifier
                            .size(24.dp)
                            .background(
                                ColorProvider(fortune.luckyColor),
                                cornerRadius = 12.dp
                            )
                    )
                    Text(
                        text = "Lucky Color",
                        style = TextStyle(fontSize = 12.sp),
                        modifier = GlanceModifier.padding(start = 8.dp)
                    )
                }
                
                // Element
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Image(
                        provider = ImageProvider(fortune.getElementIcon()),
                        contentDescription = null,
                        modifier = GlanceModifier.size(24.dp)
                    )
                    Text(
                        text = fortune.element,
                        style = TextStyle(fontSize = 12.sp),
                        modifier = GlanceModifier.padding(start = 8.dp)
                    )
                }
                
                // Update Button
                Button(
                    text = "Refresh",
                    onClick = actionRunCallback<RefreshAction>(),
                    modifier = GlanceModifier.height(32.dp)
                )
            }
        }
    }
}

class OpenAppAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}

class RefreshAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        FortuneUpdateWorker.updateWidget(context, glanceId)
    }
}
```

### 3. Widget Configuration Activity

Create `FortuneWidgetConfigActivity.kt`:

```kotlin
package com.fortune.widgets

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class FortuneWidgetConfigActivity : ComponentActivity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Get widget ID from intent
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        
        // Set result to canceled by default
        setResult(Activity.RESULT_CANCELED)
        
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        
        setContent {
            MaterialTheme {
                WidgetConfigurationScreen(
                    onConfigurationComplete = { config ->
                        saveWidgetConfiguration(config)
                        updateWidget()
                        finishConfiguration()
                    },
                    onCancel = {
                        finish()
                    }
                )
            }
        }
    }
    
    @Composable
    fun WidgetConfigurationScreen(
        onConfigurationComplete: (WidgetConfiguration) -> Unit,
        onCancel: () -> Unit
    ) {
        var selectedType by remember { mutableStateOf(FortuneType.DAILY) }
        var showLuckyNumbers by remember { mutableStateOf(true) }
        var updateFrequency by remember { mutableStateOf(UpdateFrequency.HOURLY) }
        
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Configure Fortune Widget",
                    style = MaterialTheme.typography.headlineMedium,
                    modifier = Modifier.padding(bottom = 24.dp)
                )
                
                // Fortune Type Selection
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 16.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Fortune Type",
                            style = MaterialTheme.typography.titleMedium,
                            modifier = Modifier.padding(bottom = 8.dp)
                        )
                        
                        FortuneType.values().forEach { type ->
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = selectedType == type,
                                    onClick = { selectedType = type }
                                )
                                Text(
                                    text = type.displayName,
                                    modifier = Modifier.padding(start = 8.dp)
                                )
                            }
                        }
                    }
                }
                
                // Options
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 16.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Show Lucky Numbers")
                            Switch(
                                checked = showLuckyNumbers,
                                onCheckedChange = { showLuckyNumbers = it }
                            )
                        }
                    }
                }
                
                // Update Frequency
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 24.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Update Frequency",
                            style = MaterialTheme.typography.titleMedium,
                            modifier = Modifier.padding(bottom = 8.dp)
                        )
                        
                        UpdateFrequency.values().forEach { frequency ->
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = updateFrequency == frequency,
                                    onClick = { updateFrequency = frequency }
                                )
                                Text(
                                    text = frequency.displayName,
                                    modifier = Modifier.padding(start = 8.dp)
                                )
                            }
                        }
                    }
                }
                
                Spacer(modifier = Modifier.weight(1f))
                
                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    OutlinedButton(
                        onClick = onCancel,
                        modifier = Modifier.weight(1f).padding(end = 8.dp)
                    ) {
                        Text("Cancel")
                    }
                    
                    Button(
                        onClick = {
                            onConfigurationComplete(
                                WidgetConfiguration(
                                    fortuneType = selectedType,
                                    showLuckyNumbers = showLuckyNumbers,
                                    updateFrequency = updateFrequency
                                )
                            )
                        },
                        modifier = Modifier.weight(1f).padding(start = 8.dp)
                    ) {
                        Text("Add Widget")
                    }
                }
            }
        }
    }
    
    private fun saveWidgetConfiguration(config: WidgetConfiguration) {
        val prefs = getSharedPreferences(WIDGET_PREFS_NAME, MODE_PRIVATE)
        prefs.edit().apply {
            putString("${PREF_PREFIX}_type_$appWidgetId", config.fortuneType.name)
            putBoolean("${PREF_PREFIX}_numbers_$appWidgetId", config.showLuckyNumbers)
            putString("${PREF_PREFIX}_frequency_$appWidgetId", config.updateFrequency.name)
            apply()
        }
    }
    
    private fun updateWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        FortuneWidgetProvider.updateWidget(this, appWidgetManager, appWidgetId)
    }
    
    private fun finishConfiguration() {
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(Activity.RESULT_OK, resultValue)
        finish()
    }
    
    companion object {
        const val WIDGET_PREFS_NAME = "fortune_widget_prefs"
        const val PREF_PREFIX = "widget"
    }
}

enum class FortuneType(val displayName: String) {
    DAILY("Daily Fortune"),
    LOVE("Love Fortune"),
    CAREER("Career Fortune"),
    ZODIAC("Zodiac Fortune")
}

enum class UpdateFrequency(val displayName: String) {
    HOURLY("Every Hour"),
    TWICE_DAILY("Twice a Day"),
    DAILY("Once a Day")
}

data class WidgetConfiguration(
    val fortuneType: FortuneType,
    val showLuckyNumbers: Boolean,
    val updateFrequency: UpdateFrequency
)
```

## Material You Dynamic Theming

### 1. Dynamic Color Extraction

Create `DynamicThemeService.kt`:

```kotlin
package com.fortune.services

import android.app.WallpaperManager
import android.content.Context
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.graphics.drawable.toBitmap
import androidx.palette.graphics.Palette
import com.google.android.material.color.DynamicColors
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DynamicThemeService(private val context: Context) {
    
    @RequiresApi(Build.VERSION_CODES.S)
    fun applyDynamicColors() {
        if (DynamicColors.isDynamicColorAvailable()) {
            DynamicColors.applyToActivitiesIfAvailable(context.applicationContext as Application)
        }
    }
    
    suspend fun extractWallpaperColors(): FortuneColorScheme = withContext(Dispatchers.IO) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Use Material You colors on Android 12+
            return@withContext getMaterialYouColors()
        } else {
            // Fallback to palette extraction on older versions
            return@withContext extractPaletteColors()
        }
    }
    
    @RequiresApi(Build.VERSION_CODES.S)
    private fun getMaterialYouColors(): FortuneColorScheme {
        val colors = context.resources
        return FortuneColorScheme(
            primary = colors.getColor(android.R.color.system_accent1_500, 0),
            secondary = colors.getColor(android.R.color.system_accent2_500, 0),
            tertiary = colors.getColor(android.R.color.system_accent3_500, 0),
            surface = colors.getColor(android.R.color.system_neutral1_900, 0),
            background = colors.getColor(android.R.color.system_neutral1_1000, 0)
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
    
    fun applyThemeToActivity(activity: Activity, colorScheme: FortuneColorScheme) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            activity.window.statusBarColor = colorScheme.primary
            activity.window.navigationBarColor = colorScheme.background
        }
        
        // Apply to action bar if present
        activity.actionBar?.setBackgroundDrawable(
            ColorDrawable(colorScheme.primary)
        )
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
            surface = 0xFF2C2C2C.toInt(), // Dark Gray
            background = 0xFF1A1A1A.toInt() // Very Dark Gray
        )
    }
}
```

### 2. Apply Dynamic Theme to Flutter

Create platform channel handler in `MainActivity.kt`:

```kotlin
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

## Advanced Notification Channels

### 1. Notification Service Implementation

Create `NotificationService.kt`:

```kotlin
package com.fortune.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.fortune.MainActivity
import com.fortune.R
import com.fortune.models.Fortune

class NotificationService(private val context: Context) {
    
    companion object {
        // Channel IDs
        const val CHANNEL_DAILY_FORTUNE = "daily_fortune"
        const val CHANNEL_LUCKY_TIME = "lucky_time"
        const val CHANNEL_COMPATIBILITY = "compatibility"
        const val CHANNEL_ACHIEVEMENTS = "achievements"
        const val CHANNEL_SPECIAL_EVENTS = "special_events"
        
        // Notification IDs
        const val NOTIFICATION_DAILY_FORTUNE = 1001
        const val NOTIFICATION_LUCKY_TIME = 2001
        const val NOTIFICATION_COMPATIBILITY = 3001
        const val NOTIFICATION_ACHIEVEMENT = 4001
        const val NOTIFICATION_SPECIAL_EVENT = 5001
    }
    
    init {
        createNotificationChannels()
    }
    
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            
            // Daily Fortune Channel
            val dailyFortuneChannel = NotificationChannel(
                CHANNEL_DAILY_FORTUNE,
                "Daily Fortune Updates",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Your daily fortune readings and predictions"
                enableLights(true)
                lightColor = context.getColor(R.color.fortune_gold)
                enableVibration(true)
                vibrationPattern = longArrayOf(100, 200, 100, 200)
            }
            
            // Lucky Time Channel
            val luckyTimeChannel = NotificationChannel(
                CHANNEL_LUCKY_TIME,
                "Lucky Time Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for your lucky moments"
                enableLights(true)
                lightColor = context.getColor(R.color.lucky_green)
                setShowBadge(true)
            }
            
            // Compatibility Channel
            val compatibilityChannel = NotificationChannel(
                CHANNEL_COMPATIBILITY,
                "Compatibility Matches",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Zodiac compatibility notifications"
                setShowBadge(false)
            }
            
            // Achievements Channel
            val achievementsChannel = NotificationChannel(
                CHANNEL_ACHIEVEMENTS,
                "Fortune Achievements",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Achievement unlocks and milestones"
                setShowBadge(true)
            }
            
            // Special Events Channel
            val specialEventsChannel = NotificationChannel(
                CHANNEL_SPECIAL_EVENTS,
                "Special Fortune Events",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Special astrological events and rare fortunes"
                enableLights(true)
                lightColor = context.getColor(R.color.special_purple)
                enableVibration(true)
                setBypassDnd(true)
            }
            
            notificationManager.createNotificationChannels(listOf(
                dailyFortuneChannel,
                luckyTimeChannel,
                compatibilityChannel,
                achievementsChannel,
                specialEventsChannel
            ))
        }
    }
    
    fun showDailyFortuneNotification(fortune: Fortune) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("fortune_id", fortune.id)
            putExtra("open_screen", "daily_fortune")
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_DAILY_FORTUNE)
            .setSmallIcon(R.drawable.ic_notification_fortune)
            .setLargeIcon(BitmapFactory.decodeResource(context.resources, R.drawable.ic_fortune_large))
            .setContentTitle("Your Daily Fortune is Ready! ✨")
            .setContentText("Fortune Score: ${fortune.score}/100 - ${fortune.summary}")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText(fortune.detailedMessage)
                .setBigContentTitle("${fortune.zodiacSign} Daily Fortune")
                .setSummaryText("Lucky Numbers: ${fortune.luckyNumbers.joinToString(", ")}")
            )
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .addAction(
                R.drawable.ic_share,
                "Share",
                createSharePendingIntent(fortune)
            )
            .addAction(
                R.drawable.ic_lucky_numbers,
                "Lucky Numbers",
                createLuckyNumbersPendingIntent(fortune)
            )
            .setColor(context.getColor(R.color.fortune_gold))
            .build()
        
        with(NotificationManagerCompat.from(context)) {
            notify(NOTIFICATION_DAILY_FORTUNE, notification)
        }
    }
    
    fun showLuckyTimeNotification(timeWindow: LuckyTimeWindow) {
        val notification = NotificationCompat.Builder(context, CHANNEL_LUCKY_TIME)
            .setSmallIcon(R.drawable.ic_notification_lucky_time)
            .setContentTitle("🍀 Lucky Time Alert!")
            .setContentText("Your lucky moment starts in ${timeWindow.minutesUntil} minutes")
            .setStyle(NotificationCompat.InboxStyle()
                .addLine("Duration: ${timeWindow.duration} minutes")
                .addLine("Lucky Activity: ${timeWindow.activity}")
                .addLine("Success Rate: ${timeWindow.successRate}%")
                .setSummaryText("Don't miss this opportunity!")
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setTimeoutAfter(timeWindow.duration * 60 * 1000L)
            .setColor(context.getColor(R.color.lucky_green))
            .build()
        
        with(NotificationManagerCompat.from(context)) {
            notify(NOTIFICATION_LUCKY_TIME + timeWindow.id, notification)
        }
    }
    
    fun showCompatibilityNotification(match: CompatibilityMatch) {
        val notification = NotificationCompat.Builder(context, CHANNEL_COMPATIBILITY)
            .setSmallIcon(R.drawable.ic_notification_compatibility)
            .setContentTitle("💕 Compatibility Match Found!")
            .setContentText("${match.score}% compatible with ${match.zodiacSign}")
            .setStyle(NotificationCompat.BigPictureStyle()
                .bigPicture(match.compatibilityChart)
                .bigLargeIcon(null)
                .setSummaryText(match.advice)
            )
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setColor(context.getColor(R.color.love_pink))
            .build()
        
        with(NotificationManagerCompat.from(context)) {
            notify(NOTIFICATION_COMPATIBILITY, notification)
        }
    }
    
    private fun createSharePendingIntent(fortune: Fortune): PendingIntent {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, fortune.getShareableText())
        }
        
        return PendingIntent.getActivity(
            context,
            fortune.id,
            Intent.createChooser(shareIntent, "Share Fortune"),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    private fun createLuckyNumbersPendingIntent(fortune: Fortune): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("open_screen", "lucky_numbers")
            putExtra("numbers", fortune.luckyNumbers.toIntArray())
        }
        
        return PendingIntent.getActivity(
            context,
            fortune.id + 1000,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
```

### 2. Notification Scheduling

Create `NotificationScheduler.kt`:

```kotlin
package com.fortune.services

import android.content.Context
import androidx.work.*
import java.util.Calendar
import java.util.concurrent.TimeUnit

class NotificationScheduler(private val context: Context) {
    
    fun scheduleDailyFortuneNotification(hour: Int, minute: Int) {
        val currentTime = Calendar.getInstance()
        val targetTime = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            
            // If time has passed today, schedule for tomorrow
            if (before(currentTime)) {
                add(Calendar.DAY_OF_MONTH, 1)
            }
        }
        
        val initialDelay = targetTime.timeInMillis - currentTime.timeInMillis
        
        val dailyWorkRequest = PeriodicWorkRequestBuilder<DailyFortuneWorker>(
            1, TimeUnit.DAYS
        )
            .setInitialDelay(initialDelay, TimeUnit.MILLISECONDS)
            .addTag("daily_fortune_notification")
            .build()
        
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "daily_fortune_notification",
            ExistingPeriodicWorkPolicy.REPLACE,
            dailyWorkRequest
        )
    }
    
    fun scheduleLuckyTimeNotifications(luckyTimes: List<LuckyTimeWindow>) {
        luckyTimes.forEach { luckyTime ->
            val notificationTime = luckyTime.startTime.minusMinutes(15) // 15 min before
            val delay = ChronoUnit.MINUTES.between(LocalDateTime.now(), notificationTime)
            
            if (delay > 0) {
                val luckyTimeRequest = OneTimeWorkRequestBuilder<LuckyTimeWorker>()
                    .setInitialDelay(delay, TimeUnit.MINUTES)
                    .setInputData(workDataOf(
                        "lucky_time_id" to luckyTime.id,
                        "activity" to luckyTime.activity,
                        "duration" to luckyTime.duration,
                        "success_rate" to luckyTime.successRate
                    ))
                    .addTag("lucky_time_notification")
                    .build()
                
                WorkManager.getInstance(context).enqueue(luckyTimeRequest)
            }
        }
    }
}

class DailyFortuneWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            val fortuneService = FortuneService(applicationContext)
            val fortune = fortuneService.generateDailyFortune()
            
            NotificationService(applicationContext).showDailyFortuneNotification(fortune)
            
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}

class LuckyTimeWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        val luckyTimeId = inputData.getInt("lucky_time_id", -1)
        val activity = inputData.getString("activity") ?: return Result.failure()
        val duration = inputData.getInt("duration", 30)
        val successRate = inputData.getInt("success_rate", 80)
        
        val luckyTimeWindow = LuckyTimeWindow(
            id = luckyTimeId,
            activity = activity,
            duration = duration,
            successRate = successRate,
            minutesUntil = 15
        )
        
        NotificationService(applicationContext).showLuckyTimeNotification(luckyTimeWindow)
        
        return Result.success()
    }
}
```

## Wear OS Integration

### 1. Wear OS Module Setup

Create `wear/build.gradle`:

```gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.fortune.wear'
    compileSdk 34

    defaultConfig {
        applicationId "com.fortune.wear"
        minSdk 30
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildFeatures {
        compose true
    }

    composeOptions {
        kotlinCompilerExtensionVersion '1.5.8'
    }
}

dependencies {
    implementation 'androidx.wear.compose:compose-material:1.3.0'
    implementation 'androidx.wear.compose:compose-foundation:1.3.0'
    implementation 'androidx.wear.compose:compose-navigation:1.3.0'
    implementation 'androidx.wear.tiles:tiles:1.3.0'
    implementation 'androidx.wear.watchface:watchface-complications-data-source-ktx:1.2.0'
    implementation 'com.google.android.gms:play-services-wearable:18.1.0'
}
```

### 2. Wear OS Main Activity

Create `wear/src/main/java/com/fortune/wear/MainActivity.kt`:

```kotlin
package com.fortune.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import androidx.wear.compose.material.*
import androidx.wear.compose.navigation.SwipeDismissableNavHost
import androidx.wear.compose.navigation.composable
import androidx.wear.compose.navigation.rememberSwipeDismissableNavController
import com.fortune.wear.presentation.*
import com.fortune.wear.theme.FortuneWearTheme

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
                MainScreen(
                    onNavigateToDetail = { fortuneType ->
                        navController.navigate("detail/$fortuneType")
                    }
                )
            }
            
            composable("detail/{fortuneType}") { backStackEntry ->
                val fortuneType = backStackEntry.arguments?.getString("fortuneType") ?: "daily"
                FortuneDetailScreen(fortuneType = fortuneType)
            }
        }
    }
}

@Composable
fun MainScreen(onNavigateToDetail: (String) -> Unit) {
    val listState = rememberScalingLazyListState()
    
    Scaffold(
        timeText = {
            TimeText()
        },
        vignette = {
            Vignette(vignettePosition = VignettePosition.TopAndBottom)
        },
        positionIndicator = {
            PositionIndicator(scalingLazyListState = listState)
        }
    ) {
        ScalingLazyColumn(
            modifier = Modifier.fillMaxSize(),
            state = listState,
            autoCentering = AutoCenteringParams(itemIndex = 0)
        ) {
            item {
                FortuneScoreCard(
                    score = 88,
                    onClick = { onNavigateToDetail("daily") }
                )
            }
            
            item {
                Chip(
                    onClick = { onNavigateToDetail("lucky_numbers") },
                    label = { Text("Lucky Numbers") },
                    icon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_numbers),
                            contentDescription = null
                        )
                    },
                    colors = ChipDefaults.primaryChipColors()
                )
            }
            
            item {
                Chip(
                    onClick = { onNavigateToDetail("compatibility") },
                    label = { Text("Compatibility") },
                    icon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_heart),
                            contentDescription = null
                        )
                    },
                    colors = ChipDefaults.secondaryChipColors()
                )
            }
            
            item {
                Chip(
                    onClick = { onNavigateToDetail("elements") },
                    label = { Text("Five Elements") },
                    icon = {
                        Icon(
                            painter = painterResource(R.drawable.ic_elements),
                            contentDescription = null
                        )
                    },
                    colors = ChipDefaults.secondaryChipColors()
                )
            }
        }
    }
}

@Composable
fun FortuneScoreCard(
    score: Int,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp),
        backgroundPainter = CardDefaults.cardBackgroundPainter(
            startBackgroundColor = MaterialTheme.colors.surface,
            endBackgroundColor = MaterialTheme.colors.primary.copy(alpha = 0.3f)
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Today's Fortune",
                style = MaterialTheme.typography.caption1
            )
            
            Text(
                text = "$score",
                style = MaterialTheme.typography.display1,
                color = when {
                    score >= 80 -> Color.Green
                    score >= 60 -> Color.Yellow
                    else -> Color.Red
                }
            )
            
            Text(
                text = "Tap for details",
                style = MaterialTheme.typography.caption2,
                color = MaterialTheme.colors.onSurfaceVariant
            )
        }
    }
}
```

### 3. Wear OS Tiles

Create `wear/src/main/java/com/fortune/wear/tiles/FortuneTileService.kt`:

```kotlin
package com.fortune.wear.tiles

import androidx.wear.tiles.*
import androidx.wear.tiles.LayoutElementBuilders.*
import androidx.wear.tiles.ResourceBuilders.*
import androidx.wear.tiles.TimelineBuilders.*
import androidx.wear.tiles.DimensionBuilders.*
import androidx.wear.tiles.ColorBuilders.*
import androidx.wear.tiles.ModifiersBuilders.*
import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.guava.future

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
    
    override fun onResourcesRequest(requestParams: RequestBuilders.ResourcesRequest): ListenableFuture<Resources> {
        return serviceScope.future {
            Resources.Builder()
                .setVersion(RESOURCES_VERSION)
                .addIdToImageMapping(
                    IMAGE_ID_FORTUNE,
                    ImageResource.Builder()
                        .setInlineResource(
                            InlineImageResource.Builder()
                                .setData(loadFortuneIcon())
                                .setWidthPx(48)
                                .setHeightPx(48)
                                .setFormat(ResourceBuilders.IMAGE_FORMAT_RGB_565)
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
                        Image.Builder()
                            .setResourceId(IMAGE_ID_FORTUNE)
                            .setWidth(dp(48f))
                            .setHeight(dp(48f))
                            .setModifiers(
                                Modifiers.Builder()
                                    .setPadding(
                                        Padding.Builder()
                                            .setBottom(dp(8f))
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        Text.Builder()
                            .setText("Fortune")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(sp(14f))
                                    .setWeight(FONT_WEIGHT_BOLD)
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        Text.Builder()
                            .setText("${fortune.score}/100")
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(sp(24f))
                                    .setWeight(FONT_WEIGHT_BOLD)
                                    .setColor(
                                        argb(fortune.getScoreColor())
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        Text.Builder()
                            .setText(fortune.shortMessage)
                            .setMaxLines(2)
                            .setFontStyle(
                                FontStyle.Builder()
                                    .setSize(sp(12f))
                                    .build()
                            )
                            .setModifiers(
                                Modifiers.Builder()
                                    .setPadding(
                                        Padding.Builder()
                                            .setTop(dp(4f))
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .setHorizontalAlignment(HORIZONTAL_ALIGN_CENTER)
                    .build()
            )
            .setModifiers(
                Modifiers.Builder()
                    .setPadding(
                        Padding.Builder()
                            .setAll(dp(16f))
                            .build()
                    )
                    .setClickable(
                        Clickable.Builder()
                            .setId("open_app")
                            .setOnClick(
                                LaunchAction.Builder()
                                    .setAndroidActivity(
                                        AndroidActivity.Builder()
                                            .setPackageName(packageName)
                                            .setClassName("com.fortune.wear.MainActivity")
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
    }
    
    companion object {
        private const val RESOURCES_VERSION = "1"
        private const val IMAGE_ID_FORTUNE = "fortune_icon"
    }
}
```

### 4. Wear OS Complications

Create `wear/src/main/java/com/fortune/wear/complications/FortuneComplicationService.kt`:

```kotlin
package com.fortune.wear.complications

import android.app.PendingIntent
import android.content.Intent
import android.graphics.drawable.Icon
import androidx.wear.watchface.complications.data.*
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.fortune.wear.MainActivity
import com.fortune.wear.R

class FortuneComplicationService : SuspendingComplicationDataSourceService() {
    
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val fortune = FortuneDataProvider.getCurrentFortune()
        
        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> createShortTextComplication(fortune)
            ComplicationType.LONG_TEXT -> createLongTextComplication(fortune)
            ComplicationType.RANGED_VALUE -> createRangedValueComplication(fortune)
            ComplicationType.MONOCHROMATIC_IMAGE -> createMonochromaticImageComplication(fortune)
            ComplicationType.SMALL_IMAGE -> createSmallImageComplication(fortune)
            else -> null
        }
    }
    
    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        val previewFortune = FortuneData(
            score = 88,
            message = "Great fortune awaits",
            luckyNumbers = listOf(7, 14, 21),
            element = "Fire"
        )
        
        return when (type) {
            ComplicationType.SHORT_TEXT -> createShortTextComplication(previewFortune)
            ComplicationType.LONG_TEXT -> createLongTextComplication(previewFortune)
            ComplicationType.RANGED_VALUE -> createRangedValueComplication(previewFortune)
            else -> null
        }
    }
    
    private fun createShortTextComplication(fortune: FortuneData): ComplicationData {
        return ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder("${fortune.score}").build(),
            contentDescription = PlainComplicationText.Builder("Fortune score ${fortune.score}").build()
        )
            .setTitle(PlainComplicationText.Builder("Fortune").build())
            .setTapAction(createOpenAppIntent())
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_fortune_mono)
                ).build()
            )
            .build()
    }
    
    private fun createLongTextComplication(fortune: FortuneData): ComplicationData {
        return LongTextComplicationData.Builder(
            text = PlainComplicationText.Builder(fortune.message).build(),
            contentDescription = PlainComplicationText.Builder("Fortune: ${fortune.message}").build()
        )
            .setTitle(PlainComplicationText.Builder("Today's Fortune").build())
            .setTapAction(createOpenAppIntent())
            .setSmallImage(
                SmallImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_fortune_small),
                    SmallImageType.ICON
                ).build()
            )
            .build()
    }
    
    private fun createRangedValueComplication(fortune: FortuneData): ComplicationData {
        return RangedValueComplicationData.Builder(
            value = fortune.score.toFloat(),
            min = 0f,
            max = 100f,
            contentDescription = PlainComplicationText.Builder("Fortune score ${fortune.score} out of 100").build()
        )
            .setText(PlainComplicationText.Builder("${fortune.score}").build())
            .setTitle(PlainComplicationText.Builder("Fortune").build())
            .setTapAction(createOpenAppIntent())
            .setMonochromaticImage(
                MonochromaticImage.Builder(
                    Icon.createWithResource(this, R.drawable.ic_fortune_mono)
                ).build()
            )
            .build()
    }
    
    private fun createOpenAppIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java)
        return PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
```

## Implementation Examples

### 1. Flutter Platform Channel Integration

Create Flutter service `android_native_features.dart`:

```dart
import 'package:flutter/services.dart';

class AndroidNativeFeatures {
  static const _channel = MethodChannel('com.fortune.android/native_features');
  static const _dynamicThemeChannel = MethodChannel('com.fortune.android/dynamic_theme');
  
  // Widget Management
  static Future<void> updateWidget({
    required int widgetId,
    required Map<String, dynamic> fortuneData,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'widgetId': widgetId,
        'fortuneData': fortuneData,
      });
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
  
  static Future<List<int>> getActiveWidgetIds() async {
    try {
      final List<dynamic> ids = await _channel.invokeMethod('getActiveWidgetIds');
      return ids.cast<int>();
    } catch (e) {
      print('Error getting widget IDs: $e');
      return [];
    }
  }
  
  // Dynamic Theme
  static Future<Map<String, int>?> getDynamicColors() async {
    try {
      final Map<dynamic, dynamic> colors = 
          await _dynamicThemeChannel.invokeMethod('getDynamicColors');
      return colors.cast<String, int>();
    } catch (e) {
      print('Error getting dynamic colors: $e');
      return null;
    }
  }
  
  // Notifications
  static Future<void> scheduleNotification({
    required String channelId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'channelId': channelId,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'payload': payload,
      });
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
  
  // Wear OS
  static Future<bool> isWearConnected() async {
    try {
      return await _channel.invokeMethod('isWearConnected');
    } catch (e) {
      print('Error checking Wear connection: $e');
      return false;
    }
  }
  
  static Future<void> sendToWear(Map<String, dynamic> data) async {
    try {
      await _channel.invokeMethod('sendToWear', data);
    } catch (e) {
      print('Error sending to Wear: $e');
    }
  }
}
```

### 2. Widget Update Worker

Create `FortuneUpdateWorker.kt`:

```kotlin
package com.fortune.workers

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.fortune.widgets.FortuneGlanceWidget
import com.fortune.widgets.FortuneData
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class FortuneUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            // Fetch latest fortune data
            val fortuneData = FortuneRepository.getInstance(applicationContext)
                .getLatestFortune()
            
            // Update all widgets
            FortuneGlanceWidget().updateAll(applicationContext)
            
            // Update specific widget if ID provided
            val widgetId = inputData.getInt("widgetId", -1)
            if (widgetId != -1) {
                updateSpecificWidget(widgetId, fortuneData)
            }
            
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
    
    private suspend fun updateSpecificWidget(widgetId: Int, fortuneData: FortuneData) {
        val glanceId = GlanceAppWidgetManager(applicationContext)
            .getGlanceIdBy(widgetId)
        
        updateAppWidgetState(applicationContext, glanceId) { state ->
            state[FortuneStateKeys.Score] = fortuneData.score
            state[FortuneStateKeys.Message] = fortuneData.message
            state[FortuneStateKeys.LuckyNumbers] = fortuneData.luckyNumbers.joinToString(",")
            state[FortuneStateKeys.LastUpdate] = System.currentTimeMillis()
        }
        
        FortuneGlanceWidget().update(applicationContext, glanceId)
    }
    
    companion object {
        suspend fun updateWidget(context: Context, glanceId: GlanceId) {
            val fortuneData = FortuneRepository.getInstance(context)
                .refreshFortune()
            
            updateAppWidgetState(context, glanceId) { state ->
                state[FortuneStateKeys.Score] = fortuneData.score
                state[FortuneStateKeys.Message] = fortuneData.message
                state[FortuneStateKeys.LuckyNumbers] = fortuneData.luckyNumbers.joinToString(",")
                state[FortuneStateKeys.LastUpdate] = System.currentTimeMillis()
            }
            
            FortuneGlanceWidget().update(context, glanceId)
        }
    }
}
```

## Best Practices

### 1. Performance Optimization

```kotlin
// Widget Updates
- Use WorkManager for periodic updates
- Batch widget updates when possible
- Cache fortune data locally
- Minimize network requests

// Memory Management
- Use appropriate image sizes for widgets
- Implement proper lifecycle handling
- Clear resources when widgets are removed
- Use vector drawables where possible
```

### 2. Battery Optimization

```kotlin
// Update Strategies
- Respect user's update frequency preferences
- Use device idle time for updates
- Implement exponential backoff for failures
- Batch network requests

// Background Work
- Use appropriate WorkManager constraints
- Minimize wake locks
- Respect Doze mode restrictions
```

### 3. User Experience

```kotlin
// Widget Design
- Follow Material Design guidelines
- Provide multiple widget sizes
- Support both light and dark themes
- Show meaningful loading states

// Notifications
- Use appropriate notification channels
- Respect user's notification preferences
- Provide actionable notifications
- Don't spam users
```

### 4. Testing

```kotlin
// Widget Testing
- Test all widget sizes
- Verify update mechanisms
- Test configuration changes
- Validate deep linking

// Wear OS Testing
- Test on different watch faces
- Verify complication updates
- Test connectivity scenarios
- Validate battery impact
```

## Troubleshooting

### Common Issues

1. **Widget Not Updating**
   ```kotlin
   // Check WorkManager status
   WorkManager.getInstance(context)
       .getWorkInfosByTag("widget_update")
       .get()
       .forEach { workInfo ->
           Log.d("Widget", "Work state: ${workInfo.state}")
       }
   ```

2. **Wear OS Connection Issues**
   ```kotlin
   // Verify Wear app installation
   Wearable.getNodeClient(context)
       .connectedNodes
       .await()
       .forEach { node ->
           Log.d("Wear", "Connected node: ${node.displayName}")
       }
   ```

3. **Dynamic Colors Not Working**
   ```kotlin
   // Check Android version
   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
       // Material You is supported
   } else {
       // Fall back to palette extraction
   }
   ```

## Next Steps

1. Implement widget layouts and designs
2. Set up WorkManager for updates
3. Create notification templates
4. Develop Wear OS UI
5. Test on physical devices
6. Optimize battery usage
7. Submit to Play Store