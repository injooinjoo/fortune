import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 패턴 설정
  void setPattern(BreathingPattern pattern) {
    if (state.isRunning) return;
    state = state.copyWith(
      pattern: pattern,
      currentPhase: BreathingPhase.inhale,
      phaseSecondsRemaining: pattern.inhale,
    );
    _currentPhaseTotalSeconds = pattern.inhale;
  }

  /// 시간 설정 (분 단위)
  void setDuration(int minutes) {
    if (state.isRunning) return;
    final totalSeconds = minutes * 60;
    state = state.copyWith(
      totalSecondsRemaining: totalSeconds,
      totalDurationSeconds: totalSeconds,
    );
  }

  /// 시작
  void start() {
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// 일시정지
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// 리셋
  void reset() {
    _timer?.cancel();
    _currentPhaseTotalSeconds = state.pattern.inhale;
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

    final newPhaseSeconds = state.phaseSecondsRemaining - 1;
    final newTotalSeconds = state.totalSecondsRemaining - 1;

    // 현재 단계 진행도 계산
    final progress =
        1.0 - (newPhaseSeconds / _currentPhaseTotalSeconds);

    if (newPhaseSeconds <= 0) {
      // 다음 단계로 전환
      _moveToNextPhase();
    } else {
      state = state.copyWith(
        phaseSecondsRemaining: newPhaseSeconds,
        totalSecondsRemaining: newTotalSeconds,
        progress: progress.clamp(0.0, 1.0),
      );
    }
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
      totalSecondsRemaining: state.totalSecondsRemaining - 1,
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
