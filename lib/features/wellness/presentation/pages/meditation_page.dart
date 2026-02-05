import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/meditation_sound_service.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/meditation_session.dart';
import '../providers/wellness_providers.dart';
import '../widgets/breathing_timer_widget.dart';
import '../widgets/meditation_completion_sheet.dart';

/// 명상 페이지
class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> {
  bool _wasRunning = false;
  bool _hasShownCompletion = false;

  // dispose에서 ref 사용 불가하므로 참조 저장
  MeditationSoundService? _soundService;

  @override
  void initState() {
    super.initState();
    // 초기 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _soundService = ref.read(meditationSoundServiceProvider);
      final pattern = ref.read(selectedBreathingPatternProvider);
      final duration = ref.read(selectedMeditationDurationProvider);
      ref.read(breathingTimerProvider.notifier).setPattern(pattern);
      ref.read(breathingTimerProvider.notifier).setDuration(duration);
    });
  }

  @override
  void dispose() {
    // 저장된 참조 사용 (ref는 dispose 후 사용 불가)
    _soundService?.stop();
    super.dispose();
  }

  /// 타이머 상태에 따라 배경 음악 제어
  void _handleTimerStateChange(BreathingTimerState? previous, BreathingTimerState current) {
    final soundService = ref.read(meditationSoundServiceProvider);

    // 시작: 재생
    if (current.isRunning && !_wasRunning) {
      soundService.play();
      _hasShownCompletion = false; // 새 세션 시작 시 플래그 리셋
    }
    // 일시정지: 일시정지
    else if (!current.isRunning && _wasRunning && current.totalSecondsRemaining > 0) {
      soundService.pause();
    }
    // 종료/리셋: 정지
    else if (!current.isRunning && current.totalSecondsRemaining == current.totalDurationSeconds) {
      soundService.stop();
    }
    // 시간 끝남: 정지 + 완료 화면 표시
    else if (current.totalSecondsRemaining <= 0 && !_hasShownCompletion) {
      soundService.stop();
      _hasShownCompletion = true;
      _showCompletionSheet(current);
    }

    _wasRunning = current.isRunning;
  }

  /// 명상 완료 결과 화면 표시
  void _showCompletionSheet(BreathingTimerState state) {
    final pattern = ref.read(selectedBreathingPatternProvider);
    final duration = ref.read(selectedMeditationDurationProvider);

    // 타이머 리셋
    ref.read(breathingTimerProvider.notifier).reset();

    // 완료 sheet 표시
    MeditationCompletionSheet.show(
      context,
      durationMinutes: duration,
      completedCycles: state.completedCycles,
      patternName: pattern.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final timerState = ref.watch(breathingTimerProvider);

    // 타이머 상태 변화 감지하여 배경 음악 제어
    ref.listen<BreathingTimerState>(
      breathingTimerProvider,
      _handleTimerStateChange,
    );

    return Scaffold(
      backgroundColor: isDark ? DSColors.backgroundDark : DSColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
          onPressed: () {
            if (timerState.isRunning) {
              _showExitConfirmation(context);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          '호흡 명상',
          style: context.heading3.copyWith(
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 가이드 텍스트
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getGuideText(timerState),
                  key: ValueKey(timerState.isRunning),
                  style: context.bodyLarge.copyWith(
                    color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              // 호흡 타이머
              const BreathingTimerWidget(),
              const SizedBox(height: 48),
              // 설정 섹션 (타이머 실행 중이 아닐 때만)
              AnimatedOpacity(
                opacity: timerState.isRunning ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: timerState.isRunning,
                  child: Column(
                    children: [
                      const BreathingPatternSelector(),
                      const SizedBox(height: 24),
                      const MeditationDurationSelector(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 팁 카드
              _buildTipCard(context, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getGuideText(BreathingTimerState state) {
    if (!state.isRunning && state.totalSecondsRemaining == state.totalDurationSeconds) {
      return '편안한 자세로 앉아\n호흡에 집중해보세요';
    }
    if (state.isRunning) {
      switch (state.currentPhase) {
        case BreathingPhase.inhale:
          return '코로 천천히 들이쉬세요';
        case BreathingPhase.hold:
        case BreathingPhase.holdAfterExhale:
          return '잠시 멈추세요';
        case BreathingPhase.exhale:
          return '입으로 천천히 내쉬세요';
      }
    }
    return '일시정지됨';
  }

  Widget _buildTipCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '호흡 명상 팁',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 조용하고 편안한 장소를 찾으세요\n'
            '• 등을 곧게 펴고 어깨는 편안하게\n'
            '• 눈을 감거나 한 점을 바라보세요\n'
            '• 호흡에만 집중하고 잡념을 흘려보내세요',
            style: context.bodyMedium.copyWith(
              color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final isDark = context.isDark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? DSColors.surfaceDark : DSColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '명상을 중단하시겠어요?',
          style: context.heading3.copyWith(
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        content: Text(
          '진행 중인 명상 세션이 종료됩니다.',
          style: context.bodyMedium.copyWith(
            color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '계속하기',
              style: context.bodyMedium.copyWith(
                color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(meditationSoundServiceProvider).stop();
              ref.read(breathingTimerProvider.notifier).reset();
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: Text(
              '종료',
              style: context.bodyMedium.copyWith(color: DSColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
