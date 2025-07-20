package com.fortune.fortune

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore

class NativePlatformPlugin: MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var sharedPreferences: SharedPreferences
    private var screenshotObserver: ScreenshotContentObserver? = null
    
    companion object {
        private const val CHANNEL_NAME = "com.fortune.fortune/android"
        private const val EVENT_CHANNEL_NAME = "com.fortune.fortune/android/events"
        private const val SHARED_PREFS_NAME = "FortuneWidgetPrefs"
        
        @JvmStatic
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val plugin = NativePlatformPlugin()
            plugin.context = context
            plugin.sharedPreferences = context.getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)
            
            plugin.channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            plugin.channel.setMethodCallHandler(plugin)
            
            plugin.eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
            plugin.eventChannel.setStreamHandler(plugin)
        }
    }
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "updateWidget" -> updateWidget(call, result)
            "requestNotificationPermission" -> requestNotificationPermission(result)
            "scheduleNotification" -> scheduleNotification(call, result)
            "cancelNotification" -> cancelNotification(call, result)
            "updateHomeWidget" -> updateHomeWidget(call, result)
            "getMaterialYouColors" -> getMaterialYouColors(result)
            "createNotificationChannel" -> createNotificationChannel(call, result)
            "startScreenshotDetection" -> startScreenshotDetection(result)
            "stopScreenshotDetection" -> stopScreenshotDetection(result)
            else -> result.notImplemented()
        }
    }
    
    private fun initialize(result: Result) {
        // Initialize Android components
        createDefaultNotificationChannel()
        result.success("Android platform initialized")
    }
    
    private fun createDefaultNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "fortune_default",
                "Fortune Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for fortune updates"
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun updateWidget(call: MethodCall, result: Result) {
        val widgetType = call.argument<String>("widgetType")
        val data = call.argument<Map<String, Any>>("data")
        
        if (widgetType == null || data == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
            return
        }
        
        // Store widget data
        val editor = sharedPreferences.edit()
        editor.putString("widget_$widgetType", JSONObject(data).toString())
        editor.apply()
        
        // Update app widgets
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetProvider = when (widgetType) {
            "fortune_daily" -> ComponentName(context, FortuneDailyWidget::class.java)
            "fortune_love" -> ComponentName(context, FortuneLoveWidget::class.java)
            else -> null
        }
        
        widgetProvider?.let {
            val appWidgetIds = appWidgetManager.getAppWidgetIds(it)
            val updateIntent = Intent(context, it.javaClass).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
            }
            context.sendBroadcast(updateIntent)
        }
        
        result.success("Widget updated: $widgetType")
    }
    
    private fun requestNotificationPermission(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // For Android 13+, permission needs to be requested at runtime
            // This should be handled by the Flutter side using permission_handler
            result.success(true)
        } else {
            // For older versions, notification permission is granted at install time
            result.success(true)
        }
    }
    
    private fun scheduleNotification(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val title = call.argument<String>("title")
        val body = call.argument<String>("body")
        val scheduledTime = call.argument<Long>("scheduledTime")
        val payload = call.argument<Map<String, Any>>("payload")
        
        if (id == null || title == null || body == null || scheduledTime == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
            return
        }
        
        // Build notification
        val notificationBuilder = NotificationCompat.Builder(context, "fortune_default")
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Replace with your app icon
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
        
        // Add intent if needed
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            payload?.forEach { (key, value) ->
                putExtra(key, value.toString())
            }
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        notificationBuilder.setContentIntent(pendingIntent)
        
        // Schedule notification (using WorkManager would be better for precise timing)
        CoroutineScope(Dispatchers.IO).launch {
            val delay = scheduledTime - System.currentTimeMillis()
            if (delay > 0) {
                kotlinx.coroutines.delay(delay)
            }
            
            with(NotificationManagerCompat.from(context)) {
                notify(id.hashCode(), notificationBuilder.build())
            }
        }
        
        result.success("Notification scheduled")
    }
    
    private fun cancelNotification(call: MethodCall, result: Result) {
        val id = call.argument<String>("id") ?: run {
            result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
            return
        }
        
        NotificationManagerCompat.from(context).cancel(id.hashCode())
        result.success("Notification cancelled")
    }
    
    private fun updateHomeWidget(call: MethodCall, result: Result) {
        val widgetId = call.argument<Int>("widgetId")
        val data = call.argument<Map<String, Any>>("data")
        
        if (widgetId == null || data == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
            return
        }
        
        // Store widget-specific data
        val editor = sharedPreferences.edit()
        editor.putString("widget_data_$widgetId", JSONObject(data).toString())
        editor.apply()
        
        // Update the specific widget
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val updateIntent = Intent(context, FortuneDailyWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(widgetId))
        }
        context.sendBroadcast(updateIntent)
        
        result.success("Home widget updated: $widgetId")
    }
    
    private fun getMaterialYouColors(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val colors = mutableMapOf<String, Int>()
            
            // Get Material You colors from the system
            val colorIds = mapOf(
                "primary" to android.R.color.system_accent1_500,
                "onPrimary" to android.R.color.system_accent1_0,
                "secondary" to android.R.color.system_accent2_500,
                "onSecondary" to android.R.color.system_accent2_0,
                "tertiary" to android.R.color.system_accent3_500,
                "onTertiary" to android.R.color.system_accent3_0,
                "background" to android.R.color.system_neutral1_10,
                "onBackground" to android.R.color.system_neutral1_900,
                "surface" to android.R.color.system_neutral2_50,
                "onSurface" to android.R.color.system_neutral2_900
            )
            
            colorIds.forEach { (name, id) ->
                colors[name] = context.getColor(id)
            }
            
            result.success(colors)
        } else {
            result.success(null)
        }
    }
    
    private fun createNotificationChannel(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = call.argument<String>("channelId")
            val channelName = call.argument<String>("channelName")
            val channelDescription = call.argument<String>("channelDescription")
            val importance = call.argument<Int>("importance") ?: NotificationManager.IMPORTANCE_DEFAULT
            
            if (channelId == null || channelName == null || channelDescription == null) {
                result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
                return
            }
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            
            result.success("Notification channel created: $channelId")
        } else {
            result.success("Notification channels not supported on this Android version")
        }
    }
    
    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
    
    // Screenshot detection methods
    private fun startScreenshotDetection(result: Result) {
        if (screenshotObserver == null) {
            screenshotObserver = ScreenshotContentObserver(Handler(Looper.getMainLooper())) { 
                // Send event to Flutter
                eventSink?.success(mapOf(
                    "type" to "screenshot_detected",
                    "data" to mapOf("timestamp" to System.currentTimeMillis())
                ))
            }
            
            context.contentResolver.registerContentObserver(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                true,
                screenshotObserver!!
            )
            
            result.success("Screenshot detection started")
        } else {
            result.success("Screenshot detection already active")
        }
    }
    
    private fun stopScreenshotDetection(result: Result) {
        screenshotObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
            screenshotObserver = null
            result.success("Screenshot detection stopped")
        } ?: result.success("Screenshot detection was not active")
    }
    
    // Inner class for screenshot detection
    private inner class ScreenshotContentObserver(
        handler: Handler,
        private val onScreenshot: () -> Unit
    ) : ContentObserver(handler) {
        
        private var lastDetectedTime = 0L
        private val detectionDelay = 1000L // 1 second delay to avoid duplicates
        
        override fun onChange(selfChange: Boolean, uri: Uri?) {
            super.onChange(selfChange, uri)
            
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastDetectedTime < detectionDelay) {
                return
            }
            
            uri?.let {
                // Check if the image is likely a screenshot
                if (isScreenshot(it)) {
                    lastDetectedTime = currentTime
                    onScreenshot()
                }
            }
        }
        
        private fun isScreenshot(uri: Uri): Boolean {
            val projection = arrayOf(
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DATE_ADDED
            )
            
            context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val displayNameIndex = cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME)
                    val dataIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATA)
                    val dateAddedIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATE_ADDED)
                    
                    val displayName = cursor.getString(displayNameIndex) ?: ""
                    val path = cursor.getString(dataIndex) ?: ""
                    val dateAdded = cursor.getLong(dateAddedIndex)
                    
                    // Check if file was added recently (within last 3 seconds)
                    val currentTime = System.currentTimeMillis() / 1000
                    if (currentTime - dateAdded > 3) {
                        return false
                    }
                    
                    // Check for screenshot patterns in filename or path
                    val screenshotPatterns = listOf(
                        "screenshot", "Screenshot", "SCREENSHOT",
                        "screen", "Screen", "SCREEN",
                        "스크린샷", // Korean
                        "화면 캡처" // Korean
                    )
                    
                    return screenshotPatterns.any { pattern ->
                        displayName.contains(pattern) || path.contains(pattern)
                    }
                }
            }
            
            return false
        }
    }
}