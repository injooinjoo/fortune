import 'dart:async';
import '../../domain/models/behavior_pattern.dart';

/// Follow-up 메시지 스케줄링 정보
class FollowUpSchedule {
  final String characterId;
  final int attemptNumber;
  final DateTime scheduledAt;
  final String? message;

  FollowUpSchedule({
    required this.characterId,
    required this.attemptNumber,
    required this.scheduledAt,
    this.message,
  });
}

/// Follow-up 메시지 타이머 관리 서비스
///
/// 앱 내에서 사용자 비활성 시 캐릭터가 먼저 연락하는 기능을 관리합니다.
class FollowUpScheduler {
  // 싱글톤 패턴
  static final FollowUpScheduler _instance = FollowUpScheduler._internal();
  factory FollowUpScheduler() => _instance;
  FollowUpScheduler._internal();

  // 캐릭터별 활성 타이머
  final Map<String, Timer?> _timers = {};

  // 캐릭터별 현재 시도 횟수
  final Map<String, int> _attemptCounts = {};

  // 캐릭터별 행동 패턴 캐시
  final Map<String, BehaviorPattern> _patterns = {};

  // 마지막 사용자 활동 시간
  final Map<String, DateTime> _lastUserActivity = {};

  /// Follow-up 스케줄 시작
  ///
  /// [characterId] 캐릭터 ID
  /// [pattern] 캐릭터 행동 패턴
  /// [onFollowUp] Follow-up 발생 시 콜백 (시도 횟수, 메시지 전달)
  void scheduleFollowUp({
    required String characterId,
    required BehaviorPattern pattern,
    required void Function(int attemptNumber, String? message) onFollowUp,
  }) {
    // Never 스타일은 스케줄하지 않음
    if (pattern.followUpStyle == FollowUpStyle.never) {
      return;
    }

    // 기존 타이머 취소
    cancelFollowUp(characterId);

    // 패턴 캐시
    _patterns[characterId] = pattern;

    // 사용자 활동 시간 기록
    _lastUserActivity[characterId] = DateTime.now();

    // 첫 번째 시도부터 시작
    _attemptCounts[characterId] = 0;

    // 타이머 시작
    _scheduleNextAttempt(characterId, pattern, onFollowUp);
  }

  /// 다음 Follow-up 시도 스케줄
  void _scheduleNextAttempt(
    String characterId,
    BehaviorPattern pattern,
    void Function(int attemptNumber, String? message) onFollowUp,
  ) {
    final currentAttempt = (_attemptCounts[characterId] ?? 0) + 1;

    // 최대 시도 횟수 확인
    if (!pattern.canAttemptFollowUp(currentAttempt)) {
      return;
    }

    // 딜레이 계산
    final delay = pattern.getFollowUpDelay(attemptNumber: currentAttempt);

    _timers[characterId] = Timer(delay, () {
      // 시도 횟수 증가
      _attemptCounts[characterId] = currentAttempt;

      // 메시지 가져오기
      final message = pattern.getFollowUpMessage(currentAttempt);

      // 콜백 실행
      onFollowUp(currentAttempt, message);

      // 다음 시도 스케줄 (있다면)
      if (pattern.canAttemptFollowUp(currentAttempt + 1)) {
        _scheduleNextAttempt(characterId, pattern, onFollowUp);
      }
    });
  }

  /// Follow-up 취소 (사용자가 메시지 보냈을 때)
  void cancelFollowUp(String characterId) {
    _timers[characterId]?.cancel();
    _timers[characterId] = null;
    _attemptCounts[characterId] = 0;
  }

  /// 사용자 활동 기록 (메시지 전송 시 호출)
  void recordUserActivity(String characterId) {
    _lastUserActivity[characterId] = DateTime.now();
    // 타이머 리셋 (사용자가 응답했으므로)
    final pattern = _patterns[characterId];
    if (pattern != null) {
      cancelFollowUp(characterId);
    }
  }

  /// 모든 Follow-up 취소
  void cancelAll() {
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
    _attemptCounts.clear();
    _lastUserActivity.clear();
  }

  /// 특정 캐릭터의 스케줄 활성 여부
  bool isScheduled(String characterId) {
    return _timers[characterId] != null;
  }

  /// 특정 캐릭터의 현재 시도 횟수
  int getAttemptCount(String characterId) {
    return _attemptCounts[characterId] ?? 0;
  }

  /// 마지막 사용자 활동 시간
  DateTime? getLastUserActivity(String characterId) {
    return _lastUserActivity[characterId];
  }

  /// 다음 Follow-up까지 남은 시간 (추정)
  Duration? getTimeUntilNextFollowUp(String characterId) {
    final timer = _timers[characterId];
    if (timer == null) return null;

    final lastActivity = _lastUserActivity[characterId];
    if (lastActivity == null) return null;

    final pattern = _patterns[characterId];
    if (pattern == null) return null;

    final currentAttempt = (_attemptCounts[characterId] ?? 0) + 1;
    final expectedDelay = pattern.getFollowUpDelay(attemptNumber: currentAttempt);
    final elapsed = DateTime.now().difference(lastActivity);

    final remaining = expectedDelay - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 리소스 정리 (앱 종료 시)
  void dispose() {
    cancelAll();
    _patterns.clear();
  }
}
