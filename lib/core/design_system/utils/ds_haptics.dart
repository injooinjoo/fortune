import 'package:fortune/core/utils/haptic_utils.dart';

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
    HapticUtils.lightImpact();
  }

  /// Medium impact - for button taps, selections
  static void medium() {
    HapticUtils.mediumImpact();
  }

  /// Heavy impact - for important actions, confirmations
  static void heavy() {
    HapticUtils.heavyImpact();
  }

  /// Selection click - for toggle switches, pickers
  static void selection() {
    HapticUtils.selection();
  }

  /// Vibrate - generic vibration
  static void vibrate() {
    HapticUtils.vibrate();
  }

  /// Success feedback - for successful actions
  static void success() {
    HapticUtils.success();
  }

  /// Error feedback - for error states
  static void error() {
    HapticUtils.heavyImpact();
  }

  /// Warning feedback - for warning states
  static void warning() {
    HapticUtils.mediumImpact();
  }
}
