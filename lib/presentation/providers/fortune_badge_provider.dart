import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 운세 탭 안읽음 배지 상태 관리
///
/// 사용자가 오늘 운세 탭을 방문했는지 추적합니다.
/// 매일 자정에 리셋되어 새로운 배지가 표시됩니다.
class FortuneBadgeNotifier extends StateNotifier<bool> {
  static const _lastVisitKey = 'fortune_tab_last_visit';

  FortuneBadgeNotifier() : super(true) {
    _checkBadgeStatus();
  }

  /// 배지 상태 확인 (오늘 방문했는지)
  Future<void> _checkBadgeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisit = prefs.getString(_lastVisitKey);

    if (lastVisit == null) {
      // 한 번도 방문 안함 → 배지 표시
      state = true;
      return;
    }

    final lastVisitDate = DateTime.tryParse(lastVisit);
    if (lastVisitDate == null) {
      state = true;
      return;
    }

    final today = DateTime.now();
    final isSameDay = lastVisitDate.year == today.year &&
        lastVisitDate.month == today.month &&
        lastVisitDate.day == today.day;

    // 오늘 방문했으면 배지 숨김, 아니면 표시
    state = !isSameDay;
  }

  /// 운세 탭 방문 시 호출 (배지 제거)
  Future<void> markAsRead() async {
    if (!state) return; // 이미 읽음 상태면 무시

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVisitKey, DateTime.now().toIso8601String());
    state = false;
  }

  /// 배지 강제 리셋 (테스트용)
  Future<void> resetBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastVisitKey);
    state = true;
  }
}

/// 운세 탭 안읽음 배지 표시 여부
/// true = 배지 표시 (오늘 아직 안 봄)
/// false = 배지 숨김 (오늘 이미 봄)
final fortuneBadgeProvider =
    StateNotifierProvider<FortuneBadgeNotifier, bool>((ref) {
  return FortuneBadgeNotifier();
});
