package com.beyond.fortune

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// import com.fortune.fortune.NativePlatformPlugin  // Temporarily disabled

class MainActivity: FlutterActivity() {

    companion object {
        private const val WIDGET_REFRESH_CHANNEL = "com.beyond.fortune/widget_refresh"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Schedule periodic widget refresh with WorkManager
        WidgetRefreshWorker.schedulePeriodicRefresh(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register native platform plugin - temporarily disabled
        // NativePlatformPlugin.registerWith(flutterEngine, this)

        // Set up method channel for widget refresh communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_REFRESH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleRefresh" -> {
                        WidgetRefreshWorker.schedulePeriodicRefresh(applicationContext)
                        result.success(mapOf("success" to true))
                    }
                    "cancelRefresh" -> {
                        WidgetRefreshWorker.cancelPeriodicRefresh(applicationContext)
                        result.success(mapOf("success" to true))
                    }
                    "refreshNow" -> {
                        WidgetRefreshWorker.runImmediateRefresh(applicationContext)
                        result.success(mapOf("success" to true))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
