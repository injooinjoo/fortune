import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/meditation_history.dart';
import '../../domain/models/meditation_session.dart';

/// 호흡 타이머 상태
class BreathingTimerState {
  final bool isRunning;
  final BreathingPattern pattern;
  final BreathingPhase currentPhase;
  final int phaseSecondsRemaining;
  final int totalSecondsRemaining;
  final int totalDurationSeconds;
  final int completedCycles;
  final double progress; // 0.0 ~ 1.0 현재 단계 진행도

  const BreathingTimerState({
    this.isRunning = false,
    this.pattern = BreathingPattern.pattern478,
    this.currentPhase = BreathingPhase.inhale,
    this.phaseSecondsRemaining = 4,
    this.totalSecondsRemaining = 60,
    this.totalDurationSeconds = 60,
    this.completedCycles = 0,
    this.progress = 0.0,
  });

  BreathingTimerState copyWith({
    bool? isRunning,
    BreathingPattern? pattern,
    BreathingPhase? currentPhase,
    int? phaseSecondsRemaining,
    int? totalSecondsRemaining,
    int? totalDurationSeconds,
    int? completedCycles,
    double? progress,
  }) {
    return BreathingTimerState(
      isRunning: isRunning ?? this.isRunning,
      pattern: pattern ?? this.pattern,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseSecondsRemaining:
          phaseSecondsRemaining ?? this.phaseSecondsRemaining,
      totalSecondsRemaining:
          totalSecondsRemaining ?? this.totalSecondsRemaining,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      completedCycles: completedCycles ?? this.completedCycles,
      progress: progress ?? this.progress,
    );
  }
}

/// 호흡 타이머 Notifier
class BreathingTimerNotifier extends StateNotifier<BreathingTimerState> {
  BreathingTimerNotifier() : super(const BreathingTimerState());

  Timer? _timer;
  int _currentPhaseTotalSeconds = 4;
  DateTime? _lastTick;
  int _phaseElapsedMs = 0;
  int _totalElapsedMs = 0;

  /// 패턴 설정
  void setPattern(BreathingPattern pattern) {
    if (state.isRunning) return;
    state = state.copyWith(
      pattern: pattern,
      currentPhase: BreathingPhase.inhale,
      phaseSecondsRemaining: pattern.inhale,
    );
    _currentPhaseTotalSeconds = pattern.inhale;
    _phaseElapsedMs = 0;
  }

  /// 시간 설정 (분 단위)
  void setDuration(int minutes) {
    if (state.isRunning) return;
    final totalSeconds = minutes * 60;
    state = state.copyWith(
      totalSecondsRemaining: totalSeconds,
      totalDurationSeconds: totalSeconds,
    );
    _totalElapsedMs = 0;
  }

  /// 시작
  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  /// 일시정지
  void pause() {
    _timer?.cancel();
    _lastTick = null;
    state = state.copyWith(isRunning: false);
  }

  /// 리셋
  void reset() {
    _timer?.cancel();
    _currentPhaseTotalSeconds = state.pattern.inhale;
    _phaseElapsedMs = 0;
    _totalElapsedMs = 0;
    _lastTick = null;
    state = BreathingTimerState(
      pattern: state.pattern,
      phaseSecondsRemaining: state.pattern.inhale,
      totalSecondsRemaining: state.totalDurationSeconds,
      totalDurationSeconds: state.totalDurationSeconds,
    );
  }

  void _tick() {
    if (state.totalSecondsRemaining <= 0) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
      return;
    }

    final now = DateTime.now();
    if (_lastTick == null) {
      _lastTick = now;
      return;
    }
    final deltaMs = now.difference(_lastTick!).inMilliseconds;
    if (deltaMs <= 0) return;
    _lastTick = now;

    _phaseElapsedMs += deltaMs;
    _totalElapsedMs += deltaMs;

    int newTotalSeconds = state.totalSecondsRemaining;
    while (_totalElapsedMs >= 1000 && newTotalSeconds > 0) {
      _totalElapsedMs -= 1000;
      newTotalSeconds -= 1;
    }

    while (_phaseElapsedMs >= _currentPhaseTotalSeconds * 1000) {
      _phaseElapsedMs -= _currentPhaseTotalSeconds * 1000;
      _moveToNextPhase();
    }

    final phaseSecondsRemaining =
        (_currentPhaseTotalSeconds - (_phaseElapsedMs / 1000).floor())
            .clamp(0, _currentPhaseTotalSeconds)
            .toInt();
    final progress =
        (_phaseElapsedMs / (_currentPhaseTotalSeconds * 1000)).clamp(0.0, 1.0);

    if (newTotalSeconds <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        isRunning: false,
        totalSecondsRemaining: 0,
        phaseSecondsRemaining: phaseSecondsRemaining,
        progress: progress,
      );
      return;
    }

    state = state.copyWith(
      phaseSecondsRemaining: phaseSecondsRemaining,
      totalSecondsRemaining: newTotalSeconds,
      progress: progress,
    );
  }

  void _moveToNextPhase() {
    final pattern = state.pattern;
    BreathingPhase nextPhase;
    int nextPhaseDuration;

    switch (state.currentPhase) {
      case BreathingPhase.inhale:
        nextPhase = BreathingPhase.hold;
        nextPhaseDuration = pattern.hold;
        break;
      case BreathingPhase.hold:
        nextPhase = BreathingPhase.exhale;
        nextPhaseDuration = pattern.exhale;
        break;
      case BreathingPhase.exhale:
        if (pattern.holdAfterExhale != null) {
          nextPhase = BreathingPhase.holdAfterExhale;
          nextPhaseDuration = pattern.holdAfterExhale!;
        } else {
          nextPhase = BreathingPhase.inhale;
          nextPhaseDuration = pattern.inhale;
        }
        break;
      case BreathingPhase.holdAfterExhale:
        nextPhase = BreathingPhase.inhale;
        nextPhaseDuration = pattern.inhale;
        break;
    }

    // 사이클 완료 체크
    final completedCycles = nextPhase == BreathingPhase.inhale &&
            state.currentPhase != BreathingPhase.inhale
        ? state.completedCycles + 1
        : state.completedCycles;

    _currentPhaseTotalSeconds = nextPhaseDuration;

    state = state.copyWith(
      currentPhase: nextPhase,
      phaseSecondsRemaining: nextPhaseDuration,
      completedCycles: completedCycles,
      progress: 0.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 호흡 타이머 Provider
final breathingTimerProvider =
    StateNotifierProvider<BreathingTimerNotifier, BreathingTimerState>(
  (ref) => BreathingTimerNotifier(),
);

/// 선택된 명상 시간 (분)
final selectedMeditationDurationProvider = StateProvider<int>((ref) => 1);

/// 선택된 호흡 패턴
final selectedBreathingPatternProvider = StateProvider<BreathingPattern>(
  (ref) => BreathingPattern.pattern478,
);

/// 명상 히스토리 상태
class MeditationHistoryState {
  final MeditationStatistics statistics;
  final List<MeditationHistoryEntry> recentSessions;
  final bool isLoading;

  const MeditationHistoryState({
    this.statistics = const MeditationStatistics(),
    this.recentSessions = const [],
    this.isLoading = false,
  });

  MeditationHistoryState copyWith({
    MeditationStatistics? statistics,
    List<MeditationHistoryEntry>? recentSessions,
    bool? isLoading,
  }) {
    return MeditationHistoryState(
      statistics: statistics ?? this.statistics,
      recentSessions: recentSessions ?? this.recentSessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 명상 히스토리 Notifier
class MeditationHistoryNotifier extends StateNotifier<MeditationHistoryState> {
  MeditationHistoryNotifier() : super(const MeditationHistoryState()) {
    _loadHistory();
  }

  static const _statsKey = 'meditation_statistics';
  static const _historyKey = 'meditation_history';

  /// 히스토리 로드
  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // 통계 로드
      final statsJson = prefs.getString(_statsKey);
      MeditationStatistics statistics = const MeditationStatistics();
      if (statsJson != null) {
        final statsMap = json.decode(statsJson) as Map<String, dynamic>;
        statistics = MeditationStatistics.fromJson(statsMap);
      }

      // 히스토리 로드
      final historyJson = prefs.getString(_historyKey);
      List<MeditationHistoryEntry> history = [];
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List;
        history = historyList
            .map((e) =>
                MeditationHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(
        statistics: statistics,
        recentSessions: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 명상 세션 완료 기록
  Future<void> recordSession({
    required int durationMinutes,
    required int completedCycles,
    required String patternName,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 새 엔트리 생성
    final entry = MeditationHistoryEntry(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      durationMinutes: durationMinutes,
      completedCycles: completedCycles,
      patternName: patternName,
    );

    // 연속 일수 계산
    int newConsecutiveDays = state.statistics.consecutiveDays;
    final lastDate = state.statistics.lastMeditationDate;

    if (lastDate != null) {
      final lastMeditationDay =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final daysDiff = today.difference(lastMeditationDay).inDays;

      if (daysDiff == 1) {
        // 연속 유지
        newConsecutiveDays++;
      } else if (daysDiff > 1) {
        // 연속 끊김
        newConsecutiveDays = 1;
      }
      // daysDiff == 0이면 같은 날, 연속일수 유지
    } else {
      // 첫 명상
      newConsecutiveDays = 1;
    }

    // 새 통계 계산
    final newTotalSessions = state.statistics.totalSessions + 1;
    final newTotalMinutes = state.statistics.totalMinutes + durationMinutes;

    // 원석 레벨 계산 (세션 수 기준)
    int newGemLevel = 0;
    if (newTotalSessions >= 50) {
      newGemLevel = 4;
    } else if (newTotalSessions >= 25) {
      newGemLevel = 3;
    } else if (newTotalSessions >= 10) {
      newGemLevel = 2;
    } else if (newTotalSessions >= 3) {
      newGemLevel = 1;
    }

    final newStatistics = MeditationStatistics(
      totalSessions: newTotalSessions,
      totalMinutes: newTotalMinutes,
      consecutiveDays: newConsecutiveDays,
      lastMeditationDate: now,
      currentGemLevel: newGemLevel,
    );

    // 히스토리 업데이트 (최근 30개만 유지)
    final newHistory = [entry, ...state.recentSessions].take(30).toList();

    // 상태 업데이트
    state = state.copyWith(
      statistics: newStatistics,
      recentSessions: newHistory,
    );

    // 저장
    await _saveHistory();
  }

  /// 히스토리 저장
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, json.encode(state.statistics.toJson()));
      await prefs.setString(
        _historyKey,
        json.encode(state.recentSessions.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      // 저장 실패 무시
    }
  }
}

/// 명상 히스토리 Provider
final meditationHistoryProvider =
    StateNotifierProvider<MeditationHistoryNotifier, MeditationHistoryState>(
  (ref) => MeditationHistoryNotifier(),
);
