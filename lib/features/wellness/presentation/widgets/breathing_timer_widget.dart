import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/meditation_session.dart';
import '../providers/wellness_providers.dart';

/// 호흡 타이머 원형 위젯
class BreathingTimerWidget extends ConsumerWidget {
  const BreathingTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breathingTimerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 원형 타이머
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              CustomPaint(
                size: const Size(280, 280),
                painter: _BreathingCirclePainter(
                  progress: state.progress,
                  phase: state.currentPhase,
                  primaryColor: DSColors.accent,
                  backgroundColor: isDark ? DSColors.surfaceDark : DSColors.surface,
                ),
              ),
              // 중앙 텍스트
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.currentPhase.label,
                    style: context.heading2.copyWith(
                      color: DSColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.phaseSecondsRemaining}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(state.totalSecondsRemaining),
                    style: context.bodyMedium.copyWith(
                      color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 사이클 카운터
        Text(
          '완료된 사이클: ${state.completedCycles}',
          style: context.bodyMedium.copyWith(
            color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        // 컨트롤 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.isRunning) ...[
              _ControlButton(
                icon: Icons.pause_rounded,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(breathingTimerProvider.notifier).pause();
                },
                color: DSColors.accent,
              ),
            ] else ...[
              _ControlButton(
                icon: Icons.refresh_rounded,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(breathingTimerProvider.notifier).reset();
                },
                color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(breathingTimerProvider.notifier).start();
                },
                color: DSColors.accent,
                isPrimary: true,
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// 컨트롤 버튼
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isPrimary ? 72 : 56,
        height: isPrimary ? 72 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isPrimary ? 36 : 28,
          color: isPrimary ? Colors.white : color,
        ),
      ),
    );
  }
}

/// 호흡 원형 그리기
class _BreathingCirclePainter extends CustomPainter {
  _BreathingCirclePainter({
    required this.progress,
    required this.phase,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final double progress;
  final BreathingPhase phase;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행 원
    final progressPaint = Paint()
      ..color = _getPhaseColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12시 방향에서 시작
      sweepAngle,
      false,
      progressPaint,
    );

    // 내부 원 (호흡에 따라 크기 변화)
    final innerRadius = _getInnerRadius(radius);
    final innerPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  Color _getPhaseColor() {
    switch (phase) {
      case BreathingPhase.inhale:
        return primaryColor;
      case BreathingPhase.hold:
      case BreathingPhase.holdAfterExhale:
        return primaryColor.withValues(alpha: 0.7);
      case BreathingPhase.exhale:
        return primaryColor.withValues(alpha: 0.5);
    }
  }

  double _getInnerRadius(double maxRadius) {
    final baseRadius = maxRadius * 0.3;
    final expandRadius = maxRadius * 0.5;

    switch (phase) {
      case BreathingPhase.inhale:
        // 들숨: 작은 원에서 큰 원으로
        return baseRadius + (expandRadius - baseRadius) * progress;
      case BreathingPhase.hold:
      case BreathingPhase.holdAfterExhale:
        // 멈춤: 큰 원 유지
        return expandRadius;
      case BreathingPhase.exhale:
        // 날숨: 큰 원에서 작은 원으로
        return expandRadius - (expandRadius - baseRadius) * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _BreathingCirclePainter oldDelegate) {
    return progress != oldDelegate.progress || phase != oldDelegate.phase;
  }
}

/// 호흡 패턴 선택 위젯
class BreathingPatternSelector extends ConsumerWidget {
  const BreathingPatternSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPattern = ref.watch(selectedBreathingPatternProvider);
    final timerState = ref.watch(breathingTimerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '호흡 패턴',
          style: context.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BreathingPattern.values.map((pattern) {
            final isSelected = pattern == selectedPattern;
            final isDisabled = timerState.isRunning;

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      ref.read(selectedBreathingPatternProvider.notifier).state =
                          pattern;
                      ref
                          .read(breathingTimerProvider.notifier)
                          .setPattern(pattern);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DSColors.accent
                      : isDark ? DSColors.surfaceDark : DSColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? DSColors.accent
                        : isDark ? DSColors.borderDark : DSColors.border,
                  ),
                ),
                child: Text(
                  pattern.name,
                  style: context.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                            ? (isDark ? DSColors.textSecondaryDark : DSColors.textSecondary)
                            : (isDark ? DSColors.textPrimaryDark : DSColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          selectedPattern.description,
          style: context.labelSmall.copyWith(
            color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 명상 시간 선택 위젯
class MeditationDurationSelector extends ConsumerWidget {
  const MeditationDurationSelector({super.key});

  static const List<int> _durations = [1, 3, 5, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDuration = ref.watch(selectedMeditationDurationProvider);
    final timerState = ref.watch(breathingTimerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '명상 시간',
          style: context.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _durations.map((duration) {
            final isSelected = duration == selectedDuration;
            final isDisabled = timerState.isRunning;

            return Expanded(
              child: GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(selectedMeditationDurationProvider.notifier)
                            .state = duration;
                        ref
                            .read(breathingTimerProvider.notifier)
                            .setDuration(duration);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DSColors.accent
                        : isDark ? DSColors.surfaceDark : DSColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.accent
                          : isDark ? DSColors.borderDark : DSColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$duration분',
                      style: context.bodyMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : isDisabled
                                ? (isDark ? DSColors.textSecondaryDark : DSColors.textSecondary)
                                : (isDark ? DSColors.textPrimaryDark : DSColors.textPrimary),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
