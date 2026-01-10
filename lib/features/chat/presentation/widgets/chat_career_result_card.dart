import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/infographic/headers/career_info_header.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/theme/obangseok_colors.dart';

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
  final bool isBlurred;
  final List<String> blurredSections;

  const ChatCareerResultCard({
    super.key,
    required this.fortune,
    this.isBlurred = false,
    this.blurredSections = const [],
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
      child: DSCard.hanji(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 이미지 헤더
            _buildImageHeader(context),

            // 2. 점수 섹션
            _buildScoreSection(context, data),

            // 3. 전반적인 전망 (content)
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
    final data = fortune.additionalInfo ?? {};
    final colors = context.colors;

    // 강점 데이터를 Map<String, dynamic>으로 변환
    Map<String, dynamic>? strengths;
    final skillAnalysis = data['skillAnalysis'] as List?;
    if (skillAnalysis != null && skillAnalysis.isNotEmpty) {
      strengths = {};
      for (final skill in skillAnalysis.take(3)) {
        if (skill is Map) {
          final name = skill['skill'] as String? ?? skill['name'] as String? ?? '';
          final score = skill['score'] as num? ?? skill['level'] as num? ?? 70;
          if (name.isNotEmpty) {
            strengths[name] = score;
          }
        }
      }
    }

    // 행운/주의 시기 추출
    final luckyPeriods = data['luckyPeriods'] as List?;
    final cautionPeriods = data['cautionPeriods'] as List?;

    return Stack(
      children: [
        // 인포그래픽 헤더
        CareerInfoHeader(
          score: fortune.overallScore ?? data['score'] as int? ?? 75,
          prediction: data['overallOutlook'] as String? ?? fortune.content,
          strengths: strengths,
          luckyPeriod: luckyPeriods?.isNotEmpty == true
              ? luckyPeriods!.first.toString()
              : null,
          cautionPeriod: cautionPeriods?.isNotEmpty == true
              ? cautionPeriods!.first.toString()
              : null,
        ),
        // 액션 버튼 오버레이
        Positioned(
          top: DSSpacing.sm,
          right: DSSpacing.sm,
          child: FortuneActionButtons(
            contentId: fortune.id,
            contentType: 'career',
            shareTitle: '커리어 운세',
            shareContent: fortune.content,
            iconColor: colors.textSecondary,
            iconSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;
    final score = fortune.overallScore ??
        data['score'] as int? ??
        data['careerScore'] as int? ??
        70;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          _CareerScoreCircle(score: score, size: 72),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종합 운세',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(score),
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getScoreAdvice(score),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
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
                Image.asset(
                  FortuneCardImages.getSectionIcon('work'),
                  width: 24,
                  height: 24,
                ),
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

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'predictions',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  FortuneCardImages.getSectionIcon('advice'),
                  width: 32,
                  height: 32,
                ),
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
      ),
    );
  }

  Widget _buildSkillAnalysisSection(BuildContext context, List skillAnalysis) {
    final colors = context.colors;
    final typography = context.typography;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'skillAnalysis',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  FortuneCardImages.getSectionIcon('study'),
                  width: 32,
                  height: 32,
                ),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SkillProgressBar(
                        currentLevel: currentLevel,
                        targetLevel: targetLevel,
                      ),
                    ),
                    const SizedBox(width: 8),
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

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'strengthsAssessment',
      child: Padding(
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
                  Image.asset(
                    FortuneCardImages.getSectionIcon('lucky'),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '강점',
                    style: typography.labelMedium.copyWith(
                      color: ObangseokColors.cheongMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: strengths
                    .take(3)
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                ObangseokColors.cheongMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DSRadius.sm),
                          ),
                          child: Text(
                            s.toString(),
                            style: typography.labelSmall.copyWith(
                              color: ObangseokColors.cheongMuted,
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
                  Image.asset(
                    FortuneCardImages.getSectionIcon('warning'),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '개선점',
                    style: typography.labelMedium.copyWith(
                      color: ObangseokColors.hwangMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: improvements
                    .take(3)
                    .map((i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                ObangseokColors.hwangMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DSRadius.sm),
                          ),
                          child: Text(
                            i.toString(),
                            style: typography.labelSmall.copyWith(
                              color: ObangseokColors.hwangMuted,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
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

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'actionPlan',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  FortuneCardImages.getSectionIcon('action'),
                  width: 32,
                  height: 32,
                ),
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
                color: ObangseokColors.cheongMuted,
              ),
            if (shortTerm.isNotEmpty)
              _ActionPlanItem(
                label: '단기',
                items: shortTerm.take(2).cast<String>().toList(),
                color: ObangseokColors.cheong,
              ),
            if (longTerm.isNotEmpty)
              _ActionPlanItem(
                label: '장기',
                items: longTerm.take(2).cast<String>().toList(),
                color: ObangseokColors.cheongDark,
              ),
          ],
        ),
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
                Image.asset(
                  FortuneCardImages.getSectionIcon('lucky'),
                  width: 20,
                  height: 20,
                ),
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
            const SizedBox(height: 4),
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
                Image.asset(
                  FortuneCardImages.getSectionIcon('warning'),
                  width: 20,
                  height: 20,
                ),
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
            const SizedBox(height: 4),
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

  String _getScoreDescription(int score) {
    if (score >= 90) return '최고의 커리어 운! 🌟';
    if (score >= 80) return '아주 좋은 전망이에요! ✨';
    if (score >= 70) return '좋은 기운이 함께해요';
    if (score >= 60) return '차근차근 나아가세요';
    if (score >= 50) return '신중하게 접근하세요';
    return '준비 기간으로 활용하세요';
  }

  String _getScoreAdvice(int score) {
    if (score >= 80) return '적극적으로 도전해보세요';
    if (score >= 60) return '계획대로 진행하세요';
    return '기회를 살피며 준비하세요';
  }

  Color _getProbabilityColor(int prob) {
    // 동양화 스타일 - 톤다운 오방색
    if (prob >= 75) return ObangseokColors.cheongMuted;
    if (prob >= 50) return ObangseokColors.cheong;
    if (prob >= 25) return ObangseokColors.hwangMuted;
    return ObangseokColors.jeokMuted;
  }
}

/// 점수 원형 위젯
class _CareerScoreCircle extends StatefulWidget {
  final int score;
  final double size;

  const _CareerScoreCircle({
    required this.score,
    this.size = 72,
  });

  @override
  State<_CareerScoreCircle> createState() => _CareerScoreCircleState();
}

class _CareerScoreCircleState extends State<_CareerScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final displayScore = (progress * 100).round();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreCirclePainter(
              progress: progress,
              backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
              progressColor: _getScoreColor(widget.score),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayScore',
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '점',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    // 동양화 스타일 - 톤다운 오방색
    if (score >= 80) return ObangseokColors.cheongMuted;
    if (score >= 60) return ObangseokColors.cheong;
    if (score >= 40) return ObangseokColors.hwangMuted;
    return ObangseokColors.jeokMuted;
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ScoreCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
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
                  color: ObangseokColors.cheong.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Current
            FractionallySizedBox(
              widthFactor: currentProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: ObangseokColors.cheongMuted,
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
          const SizedBox(width: 8),
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
