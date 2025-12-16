import 'package:flutter/services.dart';

/// Haptic feedback utilities
///
/// Usage:
/// ```dart
/// DSHaptics.light();
/// DSHaptics.medium();
/// DSHaptics.selection();
/// ```
class DSHaptics {
  DSHaptics._();

  /// Light impact - for subtle interactions
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for button taps, selections
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important actions, confirmations
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for toggle switches, pickers
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate - generic vibration
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  /// Success feedback - for successful actions
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error feedback - for error states
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Warning feedback - for warning states
  static void warning() {
    HapticFeedback.mediumImpact();
  }
}
