import 'package:haptic_feedback/haptic_feedback.dart';

/// 햅틱 피드백 유틸리티
class HapticUtils {
  // 가벼운 충격
  static Future<void> lightImpact() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.light);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 중간 충격
  static Future<void> mediumImpact() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.medium);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 무거운 충격
  static Future<void> heavyImpact() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.heavy);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 선택 피드백
  static Future<void> selection() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.selection);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 진동 (Android)
  static Future<void> vibrate({int duration = 100}) async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.light);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 성공 피드백
  static Future<void> success() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.success);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 경고 피드백
  static Future<void> warning() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.warning);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 에러 피드백
  static Future<void> error() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.error);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 리지드 피드백
  static Future<void> rigid() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.rigid);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }

  // 소프트 피드백
  static Future<void> soft() async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.soft);
      }
    } catch (e) {
      // 햅틱이 지원되지 않는 경우 무시
    }
  }
}