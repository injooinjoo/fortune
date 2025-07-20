package com.beyond.fortune_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.fortune.fortune.NativePlatformPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register native platform plugin
        NativePlatformPlugin.registerWith(flutterEngine, this)
    }
}