import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/tip_tag_grid.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/advice_tag.dart';
import '../score_template.dart';

/// 연애 운세용 프리셋
class LoveScoreTemplate extends StatelessWidget {
  const LoveScoreTemplate({
    super.key,
    required this.score,
    this.encounterProbability,
    this.tips,
    this.luckyPlace,
    this.luckyColor,
    this.luckyTime,
    this.luckyItem,
    this.date,
    this.isShareMode = false,
  });

  final int score;
  final int? encounterProbability;
  final List<String>? tips;
  final String? luckyPlace;
  final String? luckyColor;
  final String? luckyTime;
  final String? luckyItem;
  final DateTime? date;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 연애운',
      score: score,
      showStars: false,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildLoveContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildLoveContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (encounterProbability != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded,
                    size: 16, color: Colors.pinkAccent),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '새로운 인연 확률',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '$encounterProbability%',
                  style: context.typography.headingSmall.copyWith(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.palette_rounded,
                  label: '행운 색상',
                  value: luckyColor ?? '-',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.schedule_rounded,
                  label: '행운 시간',
                  value: luckyTime ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: '행운 아이템',
                  value: luckyItem ?? '-',
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildLuckyCell(
                  context,
                  icon: Icons.place_rounded,
                  label: '행운 장소',
                  value: luckyPlace ?? '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.pinkAccent),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 소개팅 운세 프리셋
class BlindDateScoreTemplate extends StatelessWidget {
  const BlindDateScoreTemplate({
    super.key,
    required this.score,
    this.successRate,
    this.idealType,
    this.tips,
    this.luckyPlace,
    this.keyPoints,
    this.summary,
    this.overallAdvice,
    this.isShareMode = false,
  });

  final int score;
  final int? successRate;
  final String? idealType;
  final List<String>? tips;
  final String? luckyPlace;
  final List<String>? keyPoints;
  final String? summary;
  final String? overallAdvice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 소개팅운',
      score: score,
      showStars: false,
      progressColor: Colors.pinkAccent,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (summary != null && summary!.isNotEmpty) ...[
          _buildSummarySection(context),
          const SizedBox(height: DSSpacing.md),
        ],
        if (keyPoints != null && keyPoints!.isNotEmpty) ...[
          _buildKeyPointsSection(context),
          const SizedBox(height: DSSpacing.md),
        ],
        if (overallAdvice != null && overallAdvice!.isNotEmpty) ...[
          _buildOverallAdviceSection(context),
          const SizedBox(height: DSSpacing.md),
        ],
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (successRate != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        size: 18, color: Colors.pinkAccent),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '성공 예측',
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '$successRate%',
                      style: context.typography.headingMedium.copyWith(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Icon(
                      successRate! >= 50
                          ? Icons.trending_up_rounded
                          : Icons.trending_flat_rounded,
                      size: 20,
                      color: successRate! >= 50
                          ? context.colors.success
                          : context.colors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
              ],
              if (idealType != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 14, color: Colors.pinkAccent),
                    const SizedBox(width: DSSpacing.xs),
                    Flexible(
                      child: Text(
                        '오늘의 이상형: $idealType',
                        style: context.typography.labelMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSSpacing.sm),
              ],
              if (tips != null && tips!.isNotEmpty) ...[
                TipTagGrid(
                  tips: TipTextMapper.mapTips(tips!),
                  maxVisibleTags: 4,
                  animate: !isShareMode,
                ),
              ],
              if (luckyPlace != null) ...[
                const SizedBox(height: DSSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place_rounded,
                        size: 14, color: context.colors.accent),
                    const SizedBox(width: DSSpacing.xs),
                    Text(
                      '추천 장소: $luckyPlace',
                      style: context.typography.labelSmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 16,
            color: Colors.pinkAccent.withValues(alpha: 0.6),
          ),
          const SizedBox(width: DSSpacing.xs),
          Flexible(
            child: Text(
              summary!,
              style: context.typography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallAdviceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pinkAccent.withValues(alpha: 0.08),
            Colors.amber.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 18,
            color: Colors.pinkAccent,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              overallAdvice!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    final displayPoints = keyPoints!.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.pinkAccent,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 핵심 포인트',
                style: context.typography.labelMedium.copyWith(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...displayPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayPoints.length - 1 ? DSSpacing.xs : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.typography.labelSmall.copyWith(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      point,
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 재회 운세 프리셋 (간소화 버전)
class ExLoverScoreTemplate extends StatelessWidget {
  const ExLoverScoreTemplate({
    super.key,
    required this.score,
    this.reunionProbability,
    this.currentStatus,
    this.advice,
    this.hardTruth,
    this.theirPerspective,
    this.strategicAdvice,
    this.emotionalPrescription,
    this.isShareMode = false,
  });

  final int score;
  final int? reunionProbability;
  final String? currentStatus;
  final String? advice;
  final String? hardTruth;
  final String? theirPerspective;
  final String? strategicAdvice;
  final String? emotionalPrescription;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    final displayScore = reunionProbability ?? score;

    return ScoreTemplate(
      title: '오늘의 재회운',
      score: displayScore,
      scoreLabel: '재회 가능성',
      showStars: false,
      progressColor: Colors.purple,
      bottomWidget: _buildContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildContent(BuildContext context) {
    if ((currentStatus == null || currentStatus!.isEmpty) &&
        (advice == null || advice!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentStatus != null && currentStatus!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              currentStatus!,
              style: context.typography.labelMedium.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (advice != null && advice!.isNotEmpty)
            const SizedBox(height: DSSpacing.sm),
        ],
        if (advice != null && advice!.isNotEmpty)
          AdviceTag.fromText(
            advice!,
            size: AdviceTagSize.medium,
            showQuotes: true,
            animate: !isShareMode,
          ),
      ],
    );
  }
}
