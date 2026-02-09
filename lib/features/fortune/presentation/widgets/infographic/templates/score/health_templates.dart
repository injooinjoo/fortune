import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_colors.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/tip_tag_grid.dart';
import '../score_template.dart';

/// 건강 신체 부위 데이터
class HealthBodyPart {
  const HealthBodyPart({
    required this.label,
    required this.status,
  });

  final String label;
  final HealthStatus status;
}

/// 건강 상태
enum HealthStatus { good, warning, danger }

/// 건강 운세 프리셋
class HealthScoreTemplate extends StatelessWidget {
  const HealthScoreTemplate({
    super.key,
    required this.score,
    this.bodyParts,
    this.recommendations,
    this.warningMessage,
    this.isShareMode = false,
  });

  final int score;
  final List<HealthBodyPart>? bodyParts;
  final List<String>? recommendations;
  final String? warningMessage;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 건강운',
      score: score,
      showStars: false,
      progressColor: Colors.green,
      bottomWidget: _buildHealthContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildHealthContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bodyParts != null && bodyParts!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              alignment: WrapAlignment.center,
              children: bodyParts!.map((part) {
                return _buildBodyPartChip(context, part);
              }).toList(),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        if (recommendations != null && recommendations!.isNotEmpty) ...[
          TipTagGrid(
            tips: TipTextMapper.mapTips(recommendations!),
            maxVisibleTags: 4,
            animate: !isShareMode,
          ),
        ],
        if (warningMessage != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: context.colors.warning,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    warningMessage!,
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBodyPartChip(BuildContext context, HealthBodyPart part) {
    final color = part.status == HealthStatus.good
        ? Colors.green
        : part.status == HealthStatus.warning
            ? context.colors.warning
            : context.colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            part.status == HealthStatus.good
                ? Icons.check_circle_rounded
                : part.status == HealthStatus.warning
                    ? Icons.error_rounded
                    : Icons.cancel_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            part.label,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 운동 운세 프리셋
class ExerciseScoreTemplate extends StatelessWidget {
  const ExerciseScoreTemplate({
    super.key,
    required this.score,
    this.recommendedExercise,
    this.intensity,
    this.duration,
    this.tips,
    this.isShareMode = false,
  });

  final int score;
  final String? recommendedExercise;
  final String? intensity;
  final String? duration;
  final List<String>? tips;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ScoreTemplate(
      title: '오늘의 운동운',
      score: score,
      showStars: false,
      progressColor: Colors.orange,
      bottomWidget: _buildExerciseContent(context),
      isShareMode: isShareMode,
    );
  }

  Widget _buildExerciseContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recommendedExercise != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center_rounded,
                  size: 20,
                  color: Colors.orange,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  recommendedExercise!,
                  style: context.typography.headingSmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (intensity != null)
                _buildInfoChip(context, icon: Icons.speed_rounded, label: intensity!),
              if (duration != null)
                _buildInfoChip(context, icon: Icons.timer_rounded, label: duration!),
            ],
          ),
          if (tips != null && tips!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            TipTagGrid(
              tips: TipTextMapper.mapTips(tips!),
              maxVisibleTags: 4,
              animate: !isShareMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.orange),
          const SizedBox(width: DSSpacing.xs),
          Text(
            label,
            style: context.typography.labelSmall.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 바이오리듬 인포그래픽 프리셋
class BiorhythmScoreTemplate extends StatelessWidget {
  const BiorhythmScoreTemplate({
    super.key,
    required this.physicalScore,
    required this.emotionalScore,
    required this.intellectualScore,
    this.physicalPhase,
    this.emotionalPhase,
    this.intellectualPhase,
    this.summaryPoints,
    this.overallRating = 3,
    this.advice,
    this.isShareMode = false,
  });

  final int physicalScore;
  final int emotionalScore;
  final int intellectualScore;
  final String? physicalPhase;
  final String? emotionalPhase;
  final String? intellectualPhase;
  final List<String>? summaryPoints;
  final int overallRating;
  final String? advice;
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    final averageScore =
        ((physicalScore + emotionalScore + intellectualScore) / 3).round();

    return ScoreTemplate(
      title: '오늘의 바이오리듬',
      score: averageScore,
      scoreLabel: '종합 컨디션',
      showStars: false,
      progressColor: _getOverallColor(context, averageScore),
      bottomWidget: _buildRhythmBars(context),
      isShareMode: isShareMode,
    );
  }

  Color _getOverallColor(BuildContext context, int score) {
    if (score >= 80) return context.colors.success;
    if (score >= 60) return context.colors.accent;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }

  Widget _buildRhythmBars(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (summaryPoints != null && summaryPoints!.isNotEmpty) ...[
          _buildSummarySection(context),
          const SizedBox(height: DSSpacing.md),
        ],
        _buildRhythmBar(
          context,
          icon: Icons.fitness_center_rounded,
          label: '신체',
          score: physicalScore,
          phase: physicalPhase,
          color: DSColors.error,
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.favorite_rounded,
          label: '감정',
          score: emotionalScore,
          phase: emotionalPhase,
          color: DSColors.accentSecondary,
        ),
        const SizedBox(height: DSSpacing.sm),
        _buildRhythmBar(
          context,
          icon: Icons.psychology_rounded,
          label: '지성',
          score: intellectualScore,
          phase: intellectualPhase,
          color: DSColors.info,
        ),
        const SizedBox(height: DSSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '종합 컨디션',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isFilled = index < overallRating;
                  return Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 24,
                    color: isFilled
                        ? context.colors.warning
                        : context.colors.textTertiary,
                  );
                }),
              ),
              if (advice != null) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  advice!,
                  style: context.typography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRhythmBar(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int score,
    String? phase,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$score%',
                    style: context.typography.labelSmall.copyWith(
                      color: score > 50
                          ? Colors.white
                          : context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (phase != null) ...[
          const SizedBox(width: DSSpacing.xs),
          SizedBox(
            width: 50,
            child: Text(
              phase,
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final displayPoints = summaryPoints!.take(3).toList();
    final themeColor = DSColors.accentSecondary;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: themeColor,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '오늘의 컨디션',
                style: context.typography.labelMedium.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...displayPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final icons = ['💪', '💖', '🧠'];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayPoints.length - 1 ? DSSpacing.xs : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    icons[index % icons.length],
                    style: const TextStyle(fontSize: 14),
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
