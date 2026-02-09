import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/face_reading_history_entry.dart';

/// 두 날짜 비교 분석 카드
/// 선택한 두 날짜의 분석 결과를 비교합니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class ComparisonAnalysisCard extends StatelessWidget {
  /// 비교 결과
  final HistoryComparison comparison;

  /// 첫 번째 날짜의 엔트리
  final FaceReadingHistoryEntry? entry1;

  /// 두 번째 날짜의 엔트리
  final FaceReadingHistoryEntry? entry2;

  /// 닫기 콜백
  final VoidCallback? onClose;

  const ComparisonAnalysisCard({
    super.key,
    required this.comparison,
    this.entry1,
    this.entry2,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 20),

          // 날짜 비교
          _buildDateComparison(context),
          const SizedBox(height: 20),

          // 컨디션 변화
          _buildConditionChange(context),
          const SizedBox(height: DSSpacing.md),

          // 감정 변화
          _buildEmotionChange(context),
          const SizedBox(height: DSSpacing.md),

          // 카테고리별 변화
          _buildScoreChanges(context),
          const SizedBox(height: 20),

          // 인사이트 메시지
          _buildInsightMessage(context),
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
            color: DSColors.accentSecondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.compare_arrows,
            color: DSColors.accentSecondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '변화 비교',
                style: context.labelMedium.copyWith(
                  color: context.isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '두 순간의 나를 비교해 봤어요',
                style: context.labelSmall.copyWith(
                  color: context.isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onClose != null)
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.isDark
                    ? DSColors.borderDark.withValues(alpha: 0.5)
                    : DSColors.border.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: context.isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  /// 날짜 비교
  Widget _buildDateComparison(BuildContext context) {
    final date1Str = DateFormat('M월 d일', 'ko_KR').format(comparison.date1);
    final date2Str = DateFormat('M월 d일', 'ko_KR').format(comparison.date2);

    return Row(
      children: [
        Expanded(
          child: _buildDateCard(
            context,
            date1Str,
            entry1?.overallFortuneScore,
            false,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.arrow_forward,
            color: DSColors.accent,
            size: 20,
          ),
        ),
        Expanded(
          child: _buildDateCard(
            context,
            date2Str,
            entry2?.overallFortuneScore,
            true,
          ),
        ),
      ],
    );
  }

  /// 날짜 카드
  Widget _buildDateCard(
    BuildContext context,
    String dateStr,
    int? score,
    bool isSecond,
  ) {
    final color = isSecond ? DSColors.accent : DSColors.accentSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            dateStr,
            style: context.labelMedium.copyWith(
              color: context.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '$score점',
              style: context.heading4.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 컨디션 변화
  Widget _buildConditionChange(BuildContext context) {
    final change = comparison.conditionChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '컨디션 변화',
          style: context.labelMedium.copyWith(
            color: context.isDark
                ? DSColors.textPrimaryDark
                : DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChangeItem(context, '혈색', change.complexionChange),
            ),
            Expanded(
              child: _buildChangeItem(context, '붓기', -change.puffinessChange),
            ),
            Expanded(
              child: _buildChangeItem(context, '피로도', -change.fatigueChange),
            ),
            Expanded(
              child: _buildChangeItem(context, '종합', change.overallChange),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.isDark
                ? DSColors.backgroundDark.withValues(alpha: 0.5)
                : DSColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            change.summary,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 감정 변화
  Widget _buildEmotionChange(BuildContext context) {
    final change = comparison.emotionChange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '표정 변화',
          style: context.labelMedium.copyWith(
            color: context.isDark
                ? DSColors.textPrimaryDark
                : DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChangeItem(
                context,
                '미소',
                change.smileChange.round(),
                suffix: '%',
              ),
            ),
            Expanded(
              child: _buildChangeItem(
                context,
                '긴장',
                -change.tensionChange.round(),
                suffix: '%',
              ),
            ),
            Expanded(
              child: _buildChangeItem(
                context,
                '편안함',
                change.relaxedChange.round(),
                suffix: '%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.isDark
                ? DSColors.backgroundDark.withValues(alpha: 0.5)
                : DSColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            change.summary,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 카테고리별 점수 변화
  Widget _buildScoreChanges(BuildContext context) {
    final changes = comparison.scoreChanges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리별 변화',
          style: context.labelMedium.copyWith(
            color: context.isDark
                ? DSColors.textPrimaryDark
                : DSColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildScoreChip(context, '💕 연애', changes.loveChange),
            _buildScoreChip(context, '💍 결혼', changes.marriageChange),
            _buildScoreChip(context, '💼 직업', changes.careerChange),
            _buildScoreChip(context, '💰 재물', changes.wealthChange),
            _buildScoreChip(context, '❤️ 건강', changes.healthChange),
            _buildScoreChip(context, '🤝 관계', changes.relationshipChange),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.isDark
                ? DSColors.backgroundDark.withValues(alpha: 0.5)
                : DSColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            changes.summary,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 변화 아이템
  Widget _buildChangeItem(
    BuildContext context,
    String label,
    int change, {
    String suffix = '',
  }) {
    final isPositive = change > 0;
    final isNegative = change < 0;
    final color = isPositive
        ? DSColors.success
        : isNegative
            ? DSColors.warning
            : context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary;

    return Column(
      children: [
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPositive)
              Icon(Icons.arrow_upward, color: color, size: 14)
            else if (isNegative)
              Icon(Icons.arrow_downward, color: color, size: 14)
            else
              Icon(Icons.remove, color: color, size: 14),
            Text(
              '${change.abs()}$suffix',
              style: context.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 점수 칩
  Widget _buildScoreChip(BuildContext context, String label, int change) {
    final isPositive = change > 0;
    final isNegative = change < 0;
    final color = isPositive
        ? DSColors.success
        : isNegative
            ? DSColors.warning
            : context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          if (isPositive)
            Icon(Icons.arrow_upward, color: color, size: 12)
          else if (isNegative)
            Icon(Icons.arrow_downward, color: color, size: 12)
          else
            Icon(Icons.remove, color: color, size: 12),
          Text(
            '${change.abs()}',
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 인사이트 메시지
  Widget _buildInsightMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.accent.withValues(alpha: 0.12),
            DSColors.accentSecondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text(
            '💫',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              comparison.comparisonInsight,
              style: context.bodyMedium.copyWith(
                color: context.isDark
                    ? DSColors.textPrimaryDark
                    : DSColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
