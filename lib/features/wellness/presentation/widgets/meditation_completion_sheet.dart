import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/meditation_history.dart';
import '../providers/wellness_providers.dart';
import 'mind_gem_widget.dart';

/// 명상 완료 결과 BottomSheet
class MeditationCompletionSheet extends ConsumerStatefulWidget {
  const MeditationCompletionSheet({
    super.key,
    required this.durationMinutes,
    required this.completedCycles,
    required this.patternName,
  });

  final int durationMinutes;
  final int completedCycles;
  final String patternName;

  /// BottomSheet 표시
  static Future<void> show(
    BuildContext context, {
    required int durationMinutes,
    required int completedCycles,
    required String patternName,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => MeditationCompletionSheet(
        durationMinutes: durationMinutes,
        completedCycles: completedCycles,
        patternName: patternName,
      ),
    );
  }

  @override
  ConsumerState<MeditationCompletionSheet> createState() =>
      _MeditationCompletionSheetState();
}

class _MeditationCompletionSheetState
    extends ConsumerState<MeditationCompletionSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _hasRecorded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Provider 수정은 build 이후에 해야 함 (Riverpod 규칙)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recordSession();
      }
    });
  }

  Future<void> _recordSession() async {
    if (_hasRecorded || !mounted) return;
    _hasRecorded = true;

    await ref.read(meditationHistoryProvider.notifier).recordSession(
          durationMinutes: widget.durationMinutes,
          completedCycles: widget.completedCycles,
          patternName: widget.patternName,
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyState = ref.watch(meditationHistoryProvider);
    final statistics = historyState.statistics;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? DSColors.surfaceDark : DSColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 드래그 핸들
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DSColors.borderDark
                              : DSColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 마음의 원석
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: MindGemWidget(
                          level: statistics.currentGemLevel,
                          size: 140,
                          animate: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 원석 레벨 정보
                      GemLevelInfo(
                        level: statistics.currentGemLevel,
                        totalSessions: statistics.totalSessions,
                        sessionsToNext: statistics.sessionsToNextLevel,
                      ),
                      const SizedBox(height: 24),

                      // 연속 달성 메시지
                      _buildStreakMessage(context, statistics, isDark),
                      const SizedBox(height: 24),

                      // 세션 요약
                      _buildSessionSummary(context, isDark),
                      const SizedBox(height: 24),

                      // 격려 문구
                      _buildEncouragementText(context, statistics, isDark),
                      const SizedBox(height: 32),

                      // 닫기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DSColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '오늘도 잘했어요',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakMessage(
    BuildContext context,
    MeditationStatistics statistics,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accent.withValues(alpha: 0.1),
            DSColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStreakIcon(statistics.consecutiveDays),
            color: DSColors.accent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              statistics.streakMessage,
              style: context.bodyMedium.copyWith(
                color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStreakIcon(int streak) {
    if (streak >= 30) return Icons.emoji_events_rounded;
    if (streak >= 14) return Icons.local_fire_department_rounded;
    if (streak >= 7) return Icons.favorite_rounded;
    if (streak >= 3) return Icons.spa_rounded;
    return Icons.self_improvement_rounded;
  }

  Widget _buildSessionSummary(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryItem(
          context,
          icon: Icons.timer_outlined,
          value: '${widget.durationMinutes}분',
          label: '명상 시간',
          isDark: isDark,
        ),
        Container(
          width: 1,
          height: 40,
          color: isDark ? DSColors.borderDark : DSColors.border,
        ),
        _buildSummaryItem(
          context,
          icon: Icons.loop_rounded,
          value: '${widget.completedCycles}회',
          label: '완료 사이클',
          isDark: isDark,
        ),
        Container(
          width: 1,
          height: 40,
          color: isDark ? DSColors.borderDark : DSColors.border,
        ),
        _buildSummaryItem(
          context,
          icon: Icons.air_rounded,
          value: widget.patternName.split(' ').first,
          label: '호흡 패턴',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEncouragementText(
    BuildContext context,
    MeditationStatistics statistics,
    bool isDark,
  ) {
    final messages = _getEncouragementMessages(statistics);

    return Column(
      children: [
        Text(
          messages['title']!,
          style: context.heading3.copyWith(
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          messages['subtitle']!,
          style: context.bodyMedium.copyWith(
            color: isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Map<String, String> _getEncouragementMessages(MeditationStatistics statistics) {
    final hour = DateTime.now().hour;
    final totalMinutes = statistics.totalMinutes;

    // 시간대별 메시지
    String title;
    String subtitle;

    if (hour < 6) {
      title = '새벽의 고요함 속에서';
      subtitle = '가장 깊은 평화를 찾으셨네요.\n하루를 맑은 마음으로 시작하세요.';
    } else if (hour < 12) {
      title = '평온한 아침이에요';
      subtitle = '맑은 기운으로 하루를 열었습니다.\n오늘도 좋은 일이 가득하길 바라요.';
    } else if (hour < 18) {
      title = '잠시 쉬어가는 시간';
      subtitle = '바쁜 하루 중에도 자신을 돌보셨네요.\n남은 하루도 차분하게 보내세요.';
    } else {
      title = '하루를 마무리하며';
      subtitle = '오늘의 긴장을 내려놓았습니다.\n편안한 밤 되세요.';
    }

    // 특별 업적 메시지
    if (statistics.totalSessions == 1) {
      title = '첫 명상을 축하해요!';
      subtitle = '마음 챙김의 여정이 시작되었어요.\n작은 씨앗이 자라기 시작합니다.';
    } else if (statistics.totalSessions == 10) {
      title = '10회 달성!';
      subtitle = '꾸준함이 빛을 발하고 있어요.\n당신의 원석이 자라나고 있습니다.';
    } else if (statistics.totalSessions == 50) {
      title = '명상 마스터!';
      subtitle = '50회를 달성하셨습니다.\n완성된 보석처럼 빛나는 마음이에요.';
    } else if (totalMinutes >= 1000) {
      title = '천 분의 평화';
      subtitle = '총 $totalMinutes분의 명상을 하셨어요.\n내면의 평화가 깊어지고 있습니다.';
    }

    return {'title': title, 'subtitle': subtitle};
  }
}
