import 'package:flutter/services.dart';

class VibrationService {
  static const _channel = MethodChannel('vibration');
  
  // Private constructor to prevent instantiation
  VibrationService._();
  
  /// Vibrate with default pattern
  static Future<void> vibrate({int duration = 100}) async {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Light haptic feedback
  static Future<void> light() async {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Medium haptic feedback
  static Future<void> medium() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Heavy haptic feedback
  static Future<void> heavy() async {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Selection click haptic feedback
  static Future<void> selection() async {
    try {
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Vibrate with custom pattern
  static Future<void> pattern(List<int> pattern) async {
    try {
      // For now, just use standard vibration
      // In a real app, this would use platform-specific code
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
  
  /// Check if device supports vibration
  static Future<bool> hasVibrator() async {
    try {
      // For now, assume all devices support vibration
      // In a real app, this would check device capabilities
      return true;
    } catch (e) {
      debugPrint('Fortune cached');
      return false;
    }
  }
  
  /// Cancel any ongoing vibration
  static Future<void> cancel() async {
    try {
      // Platform-specific implementation would go here
    } catch (e) {
      debugPrint('Fortune cached');
    }
  }
}