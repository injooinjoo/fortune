import 'package:flutter/material.dart';
import '../../utils/haptic_utils.dart';

/// Haptic patterns
@immutable
class HapticPatterns {
  final HapticType buttonTap;
  final HapticType success;
  final HapticType warning;
  final HapticType error;
  final HapticType selection;

  const HapticPatterns(
      {required this.buttonTap,
      required this.success,
      required this.warning,
      required this.error,
      required this.selection});

  factory HapticPatterns.standard() => const HapticPatterns(
      buttonTap: HapticType.light,
      success: HapticType.medium,
      warning: HapticType.medium,
      error: HapticType.heavy,
      selection: HapticType.selection);

  static HapticPatterns lerp(HapticPatterns a, HapticPatterns b, double t) {
    return t < 0.5 ? a : b;
  }

  /// Execute haptic feedback
  static Future<void> execute(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticType.selection:
        await HapticUtils.selection();
        break;
    }
  }
}

/// Haptic feedback types
enum HapticType { light, medium, heavy, selection }
