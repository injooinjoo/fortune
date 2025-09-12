package com.beyond.fortune

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
// import com.fortune.fortune.NativePlatformPlugin  // Temporarily disabled

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register native platform plugin - temporarily disabled
        // NativePlatformPlugin.registerWith(flutterEngine, this)
    }
}
