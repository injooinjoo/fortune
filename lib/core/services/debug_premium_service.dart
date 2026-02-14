import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

/// 디버그/테스트용 프리미엄 상태 오버라이드 서비스
/// 개발 환경 또는 테스트 계정(@test.zpzg.com)에서 작동합니다
class DebugPremiumService {
  static const String _keyPremiumOverride = 'debug_premium_override';
  static const String _keyOverrideEnabled = 'debug_premium_override_enabled';

  /// 테스트 계정인지 확인
  static bool isTestAccount(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailLower = email.toLowerCase();
    return Environment.testEmailDomains
        .any((domain) => emailLower.endsWith(domain));
  }

  /// 기능 사용 가능 여부 (디버그 모드 또는 테스트 계정)
  static bool canUseFeature(String? email) {
    return !kReleaseMode || isTestAccount(email);
  }

  /// 프리미엄 오버라이드가 활성화되어 있는지 확인
  static Future<bool> isOverrideEnabled({String? email}) async {
    if (!canUseFeature(email)) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOverrideEnabled) ?? false;
  }

  /// 프리미엄 오버라이드 값 가져오기
  static Future<bool?> getOverrideValue({String? email}) async {
    if (!canUseFeature(email)) return null;

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyOverrideEnabled) ?? false;

    if (!enabled) return null;

    return prefs.getBool(_keyPremiumOverride);
  }

  /// 프리미엄 오버라이드 설정 (true: 강제 프리미엄, false: 강제 일반, null: 오버라이드 해제)
  static Future<void> setOverride(bool? isPremium, {String? email}) async {
    if (!canUseFeature(email)) {
      debugPrint(
          '⚠️ [DebugPremiumService] Override is disabled for this account');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (isPremium == null) {
      // 오버라이드 해제
      await prefs.setBool(_keyOverrideEnabled, false);
      await prefs.remove(_keyPremiumOverride);
      debugPrint('✅ [DebugPremiumService] Premium override disabled');
    } else {
      // 오버라이드 활성화
      await prefs.setBool(_keyOverrideEnabled, true);
      await prefs.setBool(_keyPremiumOverride, isPremium);
      debugPrint('✅ [DebugPremiumService] Premium override set to: $isPremium');
    }
  }

  /// 현재 오버라이드 상태 가져오기 (디버그용)
  static Future<Map<String, dynamic>> getDebugInfo({String? email}) async {
    if (!canUseFeature(email)) {
      return {
        'available': false,
        'reason': 'Feature disabled for this account'
      };
    }

    final enabled = await isOverrideEnabled(email: email);
    final value = await getOverrideValue(email: email);

    return {
      'available': true,
      'enabled': enabled,
      'value': value,
      'mode': kDebugMode
          ? 'debug'
          : (isTestAccount(email) ? 'test_account' : 'profile'),
    };
  }

  /// 프리미엄 토글 (현재 오버라이드 값의 반대로 설정)
  static Future<bool> togglePremium({String? email}) async {
    if (!canUseFeature(email)) {
      debugPrint(
          '⚠️ [DebugPremiumService] Toggle is disabled for this account');
      return false;
    }

    final currentValue = await getOverrideValue(email: email);

    // 오버라이드가 없으면 true(프리미엄)으로 시작
    // 오버라이드가 true면 false로, false면 null(해제)로
    bool? newValue;
    if (currentValue == null) {
      newValue = true; // 없음 → 프리미엄
    } else if (currentValue == true) {
      newValue = false; // 프리미엄 → 일반
    } else {
      newValue = null; // 일반 → 오버라이드 해제
    }

    await setOverride(newValue, email: email);
    return newValue ?? false;
  }
}
