import 'package:flutter/material.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../domain/models/talent_type.dart';

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
    return TossCard(
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
            TossTheme.primaryBlue.withValues(alpha: 0.1),
            TossTheme.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(TossTheme.radiusL),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이모지
          Text(
            talentInfo.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          
          // 타입명
          Text(
            talentInfo.title,
            style: TossTheme.heading2.copyWith(
              color: TossTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // 서브타이틀
          Text(
            talentInfo.subtitle,
            style: TossTheme.subtitle1.copyWith(
              fontSize: 16,
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
                style: TossTheme.body2.copyWith(
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
        color: TossTheme.borderGray200.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
      ),
      child: Text(
        talentInfo.description,
        style: TossTheme.subtitle2.copyWith(
          height: 1.6,
          color: TossTheme.textGray600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF22C55E); // 초록
    if (score >= 70) return TossTheme.primaryBlue;    // 파랑
    if (score >= 55) return const Color(0xFFF59E0B); // 주황
    return const Color(0xFFEF4444);                  // 빨강
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
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '핵심 강점 TOP 3',
                style: TossTheme.body1.copyWith(
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
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
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
                style: TossTheme.button.copyWith(
                  color: TossDesignSystem.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: TossTheme.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.work_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '추천 직업',
                style: TossTheme.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.map((career) => _buildCareerChip(career)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerChip(String career) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TossTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        career,
        style: TossTheme.caption.copyWith(
          color: TossTheme.primaryBlue,
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
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘부터 시작할 수 있는 3가지',
                style: TossTheme.body1.copyWith(
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
        color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TossTheme.caption.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plan,
              style: TossTheme.subtitle2.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}