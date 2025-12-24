import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

/// 미소 챌린지 카드
/// "미소 짓는 관상 만들기 챌린지" - 놀이형 콘텐츠
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
/// 주의: 자기계발/노력 느낌 배제, 재미있고 가벼운 톤
class SmileChallengeCard extends StatelessWidget {
  /// 오늘의 미소 점수 (0-100)
  final int todaySmileScore;

  /// 이번 주 미소 점수 목록 (일~토)
  final List<int?> weeklySmileScores;

  /// 챌린지 달성 여부
  final bool isChallengeComplete;

  /// 다크 모드 여부
  final bool isDark;

  /// 챌린지 참여 콜백
  final VoidCallback? onJoinChallenge;

  /// 공유하기 콜백
  final VoidCallback? onShare;

  const SmileChallengeCard({
    super.key,
    required this.todaySmileScore,
    required this.weeklySmileScores,
    this.isChallengeComplete = false,
    this.isDark = false,
    this.onJoinChallenge,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isChallengeComplete
              ? [
                  DSColors.success.withValues(alpha: 0.15),
                  DSColors.accent.withValues(alpha: 0.1),
                ]
              : [
                  DSColors.accent.withValues(alpha: 0.1),
                  DSColors.accentSecondary.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChallengeComplete
              ? DSColors.success.withValues(alpha: 0.3)
              : isDark
                  ? DSColors.borderDark
                  : DSColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 16),

          // 오늘의 미소
          _buildTodaySmile(context),
          const SizedBox(height: 20),

          // 주간 미소 트래커
          _buildWeeklyTracker(context),
          const SizedBox(height: 16),

          // 액션 버튼
          _buildActionButton(context),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isChallengeComplete
                ? DSColors.success.withValues(alpha: 0.2)
                : DSColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isChallengeComplete ? '🎉' : '😊',
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isChallengeComplete ? '미소 챌린지 달성!' : '미소 챌린지',
                style: context.labelMedium.copyWith(
                  color: isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isChallengeComplete
                    ? '이번 주도 잘 웃었어요'
                    : '매일 웃으면 좋은 일이 생겨요',
                style: context.labelSmall.copyWith(
                  color: isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // 달성 배지
        if (isChallengeComplete)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: DSColors.success,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '달성',
                  style: context.labelSmall.copyWith(
                    color: DSColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 오늘의 미소 점수
  Widget _buildTodaySmile(BuildContext context) {
    final smileEmoji = _getSmileEmoji(todaySmileScore);
    final smileMessage = _getSmileMessage(todaySmileScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.backgroundDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // 미소 이모지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                smileEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 메시지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 미소',
                  style: context.labelSmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  smileMessage,
                  style: context.bodyMedium.copyWith(
                    color: isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // 점수
          Column(
            children: [
              Text(
                '$todaySmileScore',
                style: context.heading3.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '점',
                style: context.labelSmall.copyWith(
                  color: isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 주간 미소 트래커
  Widget _buildWeeklyTracker(BuildContext context) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final today = DateTime.now().weekday % 7; // 일요일 = 0

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 주 미소 기록',
          style: context.labelSmall.copyWith(
            color: isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final score = index < weeklySmileScores.length
                ? weeklySmileScores[index]
                : null;
            final isToday = index == today;
            final hasScore = score != null;

            return _buildDayCircle(
              context,
              weekdays[index],
              score,
              isToday: isToday,
              hasScore: hasScore,
            );
          }),
        ),
      ],
    );
  }

  /// 일별 원 표시
  Widget _buildDayCircle(
    BuildContext context,
    String day,
    int? score, {
    bool isToday = false,
    bool hasScore = false,
  }) {
    final color = hasScore ? _getScoreColor(score!) : DSColors.border;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: hasScore
                ? color.withValues(alpha: 0.2)
                : isDark
                    ? DSColors.borderDark.withValues(alpha: 0.3)
                    : DSColors.border.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: DSColors.accent, width: 2)
                : null,
          ),
          child: Center(
            child: hasScore
                ? Text(
                    _getSmileEmoji(score!),
                    style: const TextStyle(fontSize: 16),
                  )
                : Icon(
                    Icons.remove,
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    size: 14,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: context.labelSmall.copyWith(
            color: isToday
                ? DSColors.accent
                : isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 액션 버튼
  Widget _buildActionButton(BuildContext context) {
    if (isChallengeComplete) {
      return GestureDetector(
        onTap: onShare,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [DSColors.success, DSColors.accent],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '친구들에게 자랑하기',
                style: context.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onJoinChallenge,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DSColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: DSColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '😊',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              '오늘도 미소 남기기',
              style: context.labelMedium.copyWith(
                color: DSColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 점수에 따른 미소 이모지
  String _getSmileEmoji(int score) {
    if (score >= 80) return '😄';
    if (score >= 60) return '😊';
    if (score >= 40) return '🙂';
    if (score >= 20) return '😐';
    return '😔';
  }

  /// 점수에 따른 메시지
  String _getSmileMessage(int score) {
    if (score >= 80) return '오늘 미소가 정말 빛나요!';
    if (score >= 60) return '따뜻한 미소가 느껴져요';
    if (score >= 40) return '살짝 미소 짓고 있네요';
    if (score >= 20) return '오늘은 조금 무표정이에요';
    return '힘든 하루였나 봐요...';
  }

  /// 점수에 따른 색상
  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.accentSecondary;
  }
}
