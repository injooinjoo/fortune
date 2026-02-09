import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅용 커리어 운세 결과 카드
///
/// Edge Function 응답 필드:
/// - score, content, overallOutlook
/// - predictions[], skillAnalysis[]
/// - strengthsAssessment[], improvementAreas[]
/// - actionPlan.immediate/shortTerm/longTerm
/// - luckyPeriods[], cautionPeriods[], careerKeywords[]
class ChatCareerResultCard extends ConsumerWidget {
  final Fortune fortune;

  const ChatCareerResultCard({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // additionalInfo에서 커리어 데이터 추출
    final data = fortune.additionalInfo ?? {};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.flat(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 이미지 헤더
            _buildImageHeader(context),

            // 2. 전반적인 전망 (content)
            if (fortune.content.isNotEmpty) _buildOutlookSection(context),

            // 4. 예측 섹션 (블러)
            if (data['predictions'] != null)
              _buildPredictionsSection(context, data['predictions'] as List),

            // 5. 스킬 분석 (블러)
            if (data['skillAnalysis'] != null)
              _buildSkillAnalysisSection(
                  context, data['skillAnalysis'] as List),

            // 6. 강점/개선점 (블러)
            _buildStrengthsSection(context, data),

            // 7. 액션 플랜 (블러)
            if (data['actionPlan'] != null)
              _buildActionPlanSection(
                  context, data['actionPlan'] as Map<String, dynamic>),

            // 8. 행운/주의 시기
            _buildTimingSection(context, data),

            // 9. 키워드
            if (data['careerKeywords'] != null)
              _buildKeywordsSection(context, data['careerKeywords'] as List),

            const SizedBox(height: DSSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = fortune.overallScore ?? 75;
    final heroImage = FortuneCardImages.getHeroImage('career', score);

    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 이미지
          SmartImage(
            path: heroImage,
            fit: BoxFit.cover,
            errorWidget: SmartImage(
              path: FortuneCardImages.getImagePath('career'),
              fit: BoxFit.cover,
            ),
          ),

          // 2. 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DSColors.info.withValues(alpha: 0.15),
                  colors.background.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),

          // 3. 뱃지 (좌상단)
          Positioned(
            top: DSSpacing.sm,
            left: DSSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DSColors.info.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💼', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    'CAREER',
                    style: typography.labelSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. 액션 버튼 (우상단)
          Positioned(
            top: DSSpacing.sm,
            right: DSSpacing.sm,
            child: FortuneActionButtons(
              contentId: fortune.id,
              contentType: 'career',
              fortuneType: 'career',
              shareTitle: '커리어 운세',
              shareContent: fortune.content,
              iconColor: colors.textPrimary,
              iconSize: 20,
            ),
          ),

          // 5. 타이틀 & 점수 (하단)
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '커리어 운세',
                        style: typography.headingSmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: colors.background.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '직업 · 이직 · 승진',
                        style: typography.labelMedium.copyWith(
                          color: colors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // 점수 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: colors.surface.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: typography.headingSmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '점',
                        style: typography.labelSmall.copyWith(
                          color: colors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlookSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 20)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '전반적인 전망',
                  style: typography.labelLarge.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              fortune.content,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsSection(BuildContext context, List predictions) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '커리어 예측',
                style: typography.labelLarge.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...predictions.take(2).map((prediction) {
            final pred = prediction as Map<String, dynamic>;
            final timeframe = pred['timeframe'] as String? ?? '';
            final probability = pred['probability'] as int? ?? 0;
            final milestones = pred['keyMilestones'] as List? ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.sm),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeframe,
                        style: typography.labelMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getProbabilityColor(probability)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '$probability% 확률',
                          style: typography.labelSmall.copyWith(
                            color: _getProbabilityColor(probability),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (milestones.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...milestones.take(2).map((m) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '•',
                                style: typography.bodySmall.copyWith(
                                  color: colors.accentSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  m.toString(),
                                  style: typography.bodySmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSkillAnalysisSection(BuildContext context, List skillAnalysis) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '스킬 분석',
                style: typography.labelLarge.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...skillAnalysis.take(3).map((skill) {
            final s = skill as Map<String, dynamic>;
            final skillName = s['skill'] as String? ?? '';
            final currentLevel = s['currentLevel'] as int? ?? 5;
            final targetLevel = s['targetLevel'] as int? ?? 8;

            return Container(
              margin: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      skillName,
                      style: typography.labelSmall.copyWith(
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: _SkillProgressBar(
                      currentLevel: currentLevel,
                      targetLevel: targetLevel,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    'Lv.$currentLevel→$targetLevel',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
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

  Widget _buildStrengthsSection(
      BuildContext context, Map<String, dynamic> data) {
    final typography = context.typography;
    final strengths = data['strengthsAssessment'] as List? ?? [];
    final improvements = data['improvementAreas'] as List? ?? [];

    if (strengths.isEmpty && improvements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (strengths.isNotEmpty) ...[
            Row(
              children: [
                const Text('💪', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '강점',
                  style: typography.labelMedium.copyWith(
                    color: DSColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: strengths
                  .take(3)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DSColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          s.toString(),
                          style: typography.labelSmall.copyWith(
                            color: DSColors.info,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (improvements.isNotEmpty) ...[
            Row(
              children: [
                const Text('🔧', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '개선점',
                  style: typography.labelMedium.copyWith(
                    color: DSColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: improvements
                  .take(3)
                  .map((i) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DSColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          i.toString(),
                          style: typography.labelSmall.copyWith(
                            color: DSColors.warning,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionPlanSection(
      BuildContext context, Map<String, dynamic> actionPlan) {
    final colors = context.colors;
    final typography = context.typography;

    final immediate = actionPlan['immediate'] as List? ?? [];
    final shortTerm = actionPlan['shortTerm'] as List? ?? [];
    final longTerm = actionPlan['longTerm'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '액션 플랜',
                style: typography.labelLarge.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          if (immediate.isNotEmpty)
            _ActionPlanItem(
              label: '즉시',
              items: immediate.take(2).cast<String>().toList(),
              color: DSColors.info,
            ),
          if (shortTerm.isNotEmpty)
              _ActionPlanItem(
                label: '단기',
                items: shortTerm.take(2).cast<String>().toList(),
                color: DSColors.info,
              ),
            if (longTerm.isNotEmpty)
            _ActionPlanItem(
              label: '장기',
              items: longTerm.take(2).cast<String>().toList(),
              color: DSColors.info,
            ),
        ],
      ),
    );
  }

  Widget _buildTimingSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;
    final luckyPeriods = data['luckyPeriods'] as List? ?? [];
    final cautionPeriods = data['cautionPeriods'] as List? ?? [];

    if (luckyPeriods.isEmpty && cautionPeriods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (luckyPeriods.isNotEmpty) ...[
            Row(
              children: [
                const Text('🍀', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '행운 시기',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              luckyPeriods.take(2).join(', '),
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (cautionPeriods.isNotEmpty) ...[
            Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '주의 시기',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              cautionPeriods.take(2).join(', '),
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeywordsSection(BuildContext context, List keywords) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: keywords
            .take(5)
            .map((k) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.textPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: colors.textPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '#${k.toString()}',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Color _getProbabilityColor(int prob) {
    // 동양화 스타일 - 톤다운 오방색
    if (prob >= 75) return DSColors.info;
    if (prob >= 50) return DSColors.info;
    if (prob >= 25) return DSColors.warning;
    return DSColors.error;
  }
}

/// 스킬 진행 바
class _SkillProgressBar extends StatelessWidget {
  final int currentLevel;
  final int targetLevel;

  const _SkillProgressBar({
    required this.currentLevel,
    required this.targetLevel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentProgress = currentLevel / 10;
    final targetProgress = targetLevel / 10;

    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Background
            Container(
              color: colors.textPrimary.withValues(alpha: 0.1),
            ),
            // Target (dotted)
            FractionallySizedBox(
              widthFactor: targetProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: DSColors.info.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Current
            FractionallySizedBox(
              widthFactor: currentProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: DSColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 액션 플랜 아이템
class _ActionPlanItem extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;

  const _ActionPlanItem({
    required this.label,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Text(
              label,
              style: typography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              items.join(', '),
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
