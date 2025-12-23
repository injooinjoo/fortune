import 'package:flutter/material.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/talent_type.dart';

// Korean Traditional Design System - Talent Type Result Widget

/// 재능 타입 결과를 표시하는 메인 위젯
class TalentTypeResultWidget extends StatelessWidget {
  final TalentTypeInfo talentInfo;
  final int overallScore;

  const TalentTypeResultWidget({
    super.key,
    required this.talentInfo,
    required this.overallScore,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 메인 타입 카드
          _buildMainTypeCard(context),
          const SizedBox(height: 20),
          
          // 전체 점수
          _buildOverallScore(context),
          const SizedBox(height: 16),
          
          // 설명
          _buildDescription(context),
        ],
      ),
    );
  }

  Widget _buildMainTypeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.accent.withValues(alpha: 0.1),
            DSColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이모지
          Text(
            talentInfo.emoji,
            style: context.displayLarge,
          ),
          const SizedBox(height: 12),

          // 타입명
          Text(
            talentInfo.title,
            style: context.heading2.copyWith(
              color: DSColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // 서브타이틀
          Text(
            talentInfo.subtitle,
            style: context.bodyLarge.copyWith(

              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getScoreColor(overallScore).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getScoreColor(overallScore).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: _getScoreColor(overallScore),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '재능 점수 $overallScore점',
                style: context.bodyMedium.copyWith(
                  color: _getScoreColor(overallScore),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Text(
        talentInfo.description,
        style: context.bodyMedium.copyWith(
          height: 1.6,
          color: DSColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return DSColors.success; // 초록
    if (score >= 70) return DSColors.accent;    // 파랑
    if (score >= 55) return DSColors.warning; // 주황
    return DSColors.error;                  // 빨강
  }
}

/// 재능 강점 카드들
class TalentStrengthCards extends StatelessWidget {
  final List<String> strengths;

  const TalentStrengthCards({
    super.key,
    required this.strengths,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: DSColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '핵심 강점 TOP 3',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...strengths.asMap().entries.map((entry) {
            final index = entry.key;
            final strength = entry.value;
            return _buildStrengthItem(context, index + 1, strength);
          }),
        ],
      ),
    );
  }

  Widget _buildStrengthItem(BuildContext context, int rank, String strength) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      const Color(0xFFFFD700), // 금색
      const Color(0xFFC0C0C0), // 은색
      const Color(0xFFCD7F32), // 동색
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors[rank - 1].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors[rank - 1].withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors[rank - 1],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: context.labelMedium.copyWith(
                  color: Colors.white,

                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 추천 커리어 위젯
class RecommendedCareersWidget extends StatelessWidget {
  final List<String> careers;

  const RecommendedCareersWidget({
    super.key,
    required this.careers,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.work_rounded,
                color: DSColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '추천 직업',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.map((career) => _buildCareerChip(context, career)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerChip(BuildContext context, String career) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DSColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        career,
        style: context.labelSmall.copyWith(
          color: DSColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 액션 플랜 위젯
class ActionPlanWidget extends StatelessWidget {
  final List<String> actionPlans;

  const ActionPlanWidget({
    super.key,
    required this.actionPlans,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: DSColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘부터 시작할 수 있는 3가지',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...actionPlans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            return _buildActionItem(context, index + 1, plan);
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, int step, String plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : DSColors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DSColors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$step',
                style: context.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plan,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}