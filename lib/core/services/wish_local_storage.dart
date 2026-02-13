import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/fortune/domain/models/wish_fortune_result.dart';

/// 소원 빌기 로컬 저장소
///
/// SharedPreferences를 사용하여 소원 히스토리를 로컬에 저장합니다.
/// - 최대 20개 저장
/// - 하루 3회 제한 체크
class WishLocalStorage {
  static const String _historyKey = 'wish_history';
  static const String _todayCountKey = 'wish_today_count';
  static const String _todayDateKey = 'wish_today_date';
  static const int maxHistory = 20;
  static const int dailyLimit = 3;

  /// 소원 저장
  static Future<void> saveWish(WishFortuneResult wish) async {
    final prefs = await SharedPreferences.getInstance();

    // 기존 히스토리 로드
    final history = await getHistory();

    // 새 소원을 맨 앞에 추가
    final newHistory = [wish, ...history];

    // 최대 개수 제한
    final limitedHistory = newHistory.take(maxHistory).toList();

    // JSON으로 변환하여 저장
    final jsonList = limitedHistory.map((w) => w.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));

    // 오늘 횟수 증가
    await _incrementTodayCount();
  }

  /// 히스토리 조회
  static Future<List<WishFortuneResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => WishFortuneResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 파싱 실패 시 빈 리스트 반환
      return [];
    }
  }

  /// 오늘 소원 횟수 조회
  static Future<int> getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();

    // 날짜 체크 - 새 날이면 리셋
    final today = _getTodayString();
    final savedDate = prefs.getString(_todayDateKey);

    if (savedDate != today) {
      // 새 날짜 - 카운트 리셋
      await prefs.setString(_todayDateKey, today);
      await prefs.setInt(_todayCountKey, 0);
      return 0;
    }

    return prefs.getInt(_todayCountKey) ?? 0;
  }

  /// 남은 소원 횟수 조회
  static Future<int> getRemainingToday() async {
    final count = await getTodayCount();
    return (dailyLimit - count).clamp(0, dailyLimit);
  }

  /// 오늘 소원을 더 빌 수 있는지 확인
  static Future<bool> canMakeWishToday() async {
    final remaining = await getRemainingToday();
    return remaining > 0;
  }

  /// 오늘 횟수 증가
  static Future<void> _incrementTodayCount() async {
    final prefs = await SharedPreferences.getInstance();

    // 날짜 체크 - 새 날이면 리셋
    final today = _getTodayString();
    final savedDate = prefs.getString(_todayDateKey);

    if (savedDate != today) {
      await prefs.setString(_todayDateKey, today);
      await prefs.setInt(_todayCountKey, 1);
    } else {
      final currentCount = prefs.getInt(_todayCountKey) ?? 0;
      await prefs.setInt(_todayCountKey, currentCount + 1);
    }
  }

  /// 히스토리 전체 삭제 (디버그/테스트용)
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_todayCountKey);
    await prefs.remove(_todayDateKey);
  }

  /// 오늘 날짜 문자열 (YYYY-MM-DD)
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
