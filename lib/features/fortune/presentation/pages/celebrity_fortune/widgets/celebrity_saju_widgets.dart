import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 사주 분석 섹션 (오행, 일주, 합)
class SajuAnalysisSection extends StatelessWidget {
  final Map<String, dynamic>? sajuAnalysis;

  const SajuAnalysisSection({super.key, required this.sajuAnalysis});

  @override
  Widget build(BuildContext context) {
    if (sajuAnalysis == null) return const SizedBox.shrink();

    final colors = context.colors;
    final fiveElements = sajuAnalysis!['five_elements'] as Map<String, dynamic>?;
    final dayPillar = sajuAnalysis!['day_pillar'] as Map<String, dynamic>?;
    final hapAnalysis = sajuAnalysis!['hap_analysis'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: DSColors.accentSecondary, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '사주 심층 분석',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // 오행 분석
          if (fiveElements != null) ...[
            _FiveElementsCard(fiveElements: fiveElements),
            const SizedBox(height: DSSpacing.md),
          ],

          // 일주 궁합
          if (dayPillar != null) ...[
            _DayPillarCard(dayPillar: dayPillar),
            const SizedBox(height: DSSpacing.md),
          ],

          // 합(合) 해석
          if (hapAnalysis != null) _HapAnalysisCard(hapAnalysis: hapAnalysis),
        ],
      ),
    );
  }
}

/// 오행 분석 카드
class _FiveElementsCard extends StatelessWidget {
  final Map<String, dynamic> fiveElements;

  const _FiveElementsCard({required this.fiveElements});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userDominant = fiveElements['user_dominant'] as String? ?? '';
    final celebrityDominant = fiveElements['celebrity_dominant'] as String? ?? '';
    final interaction = fiveElements['interaction'] as String? ?? '';
    final interpretation = fiveElements['interpretation'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: _getElementColor(userDominant).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: _getElementColor(userDominant).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getElementColor(userDominant),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  '五行',
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '오행 분석',
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 오행 비교
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ElementBadge(element: userDominant, label: '나'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Icon(
                      _getInteractionIcon(interaction),
                      color: _getInteractionColor(interaction),
                      size: 28,
                    ),
                    Text(
                      interaction,
                      style: DSTypography.labelSmall.copyWith(
                        color: _getInteractionColor(interaction),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ElementBadge(element: celebrityDominant, label: '유명인'),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 해석
          Text(
            interpretation,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '木':
        return const Color(0xFF4CAF50); // 초록 (목)
      case '火':
        return const Color(0xFFE53935); // 빨강 (화)
      case '土':
        return const Color(0xFFFF9800); // 노랑/주황 (토)
      case '金':
        return const Color(0xFF9E9E9E); // 흰/회색 (금)
      case '水':
        return const Color(0xFF2196F3); // 파랑 (수)
      default:
        return DSColors.accent;
    }
  }

  IconData _getInteractionIcon(String interaction) {
    switch (interaction) {
      case '상생':
        return Icons.favorite;
      case '상극':
        return Icons.flash_on;
      case '비화':
        return Icons.handshake;
      default:
        return Icons.compare_arrows;
    }
  }

  Color _getInteractionColor(String interaction) {
    switch (interaction) {
      case '상생':
        return DSColors.success;
      case '상극':
        return DSColors.warning;
      case '비화':
        return DSColors.accent;
      default:
        return DSColors.accent;
    }
  }
}

/// 오행 배지
class _ElementBadge extends StatelessWidget {
  final String element;
  final String label;

  const _ElementBadge({required this.element, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getElementColor(element),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              element,
              style: DSTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DSTypography.labelSmall.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '木':
        return const Color(0xFF4CAF50);
      case '火':
        return const Color(0xFFE53935);
      case '土':
        return const Color(0xFFFF9800);
      case '金':
        return const Color(0xFF9E9E9E);
      case '水':
        return const Color(0xFF2196F3);
      default:
        return DSColors.accent;
    }
  }
}

/// 일주 궁합 카드
class _DayPillarCard extends StatelessWidget {
  final Map<String, dynamic> dayPillar;

  const _DayPillarCard({required this.dayPillar});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final relationship = dayPillar['relationship'] as String? ?? '';
    final interpretation = dayPillar['interpretation'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.accent,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  '日柱',
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '일주 궁합',
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: Text(
                  relationship,
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DSColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            interpretation,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 합(合) 해석 카드
class _HapAnalysisCard extends StatelessWidget {
  final Map<String, dynamic> hapAnalysis;

  const _HapAnalysisCard({required this.hapAnalysis});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasHap = hapAnalysis['has_hap'] as bool? ?? false;
    final hapType = hapAnalysis['hap_type'] as String?;
    final interpretation = hapAnalysis['interpretation'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: hasHap
            ? DSColors.success.withValues(alpha: 0.1)
            : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: hasHap
              ? DSColors.success.withValues(alpha: 0.3)
              : colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasHap ? DSColors.success : colors.textTertiary,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  '合',
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '합(合) 분석',
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (hasHap && hapType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: DSColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: DSColors.success),
                      const SizedBox(width: 4),
                      Text(
                        hapType,
                        style: DSTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DSColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            interpretation,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 전생 인연 섹션
class PastLifeSection extends StatelessWidget {
  final Map<String, dynamic>? pastLife;

  const PastLifeSection({super.key, required this.pastLife});

  @override
  Widget build(BuildContext context) {
    if (pastLife == null) return const SizedBox.shrink();

    final colors = context.colors;
    final connectionType = pastLife!['connection_type'] as String? ?? '';
    final story = pastLife!['story'] as String? ?? '';
    final evidence = (pastLife!['evidence'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B5CE7).withValues(alpha: 0.1),
            const Color(0xFF8A7EFF).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: const Color(0xFF6B5CE7).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B5CE7), Color(0xFF8A7EFF)],
                  ),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: const Icon(Icons.history, color: Colors.white, size: 20),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '전생 인연',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5CE7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSRadius.full),
                ),
                child: Text(
                  connectionType,
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B5CE7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // 스토리
          Text(
            story,
            style: DSTypography.bodySmall.copyWith(
              height: 1.8,
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),

          if (evidence.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.lg),
            Text(
              '사주에서 발견한 증거',
              style: DSTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            ...evidence.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: const Color(0xFF6B5CE7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: DSTypography.labelSmall.copyWith(
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
  }
}

/// 운명의 시기 섹션
class DestinedTimingSection extends StatelessWidget {
  final Map<String, dynamic>? destinedTiming;

  const DestinedTimingSection({super.key, required this.destinedTiming});

  @override
  Widget build(BuildContext context) {
    if (destinedTiming == null) return const SizedBox.shrink();

    final colors = context.colors;
    final bestYear = destinedTiming!['best_year'] as String? ?? '';
    final bestMonth = destinedTiming!['best_month'] as String? ?? '';
    final timingReason = destinedTiming!['timing_reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: DSColors.warning, size: 24),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '운명의 시기',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // 시기 카드들
          Row(
            children: [
              Expanded(
                child: _TimingCard(
                  icon: Icons.event,
                  label: '최적의 해',
                  value: bestYear,
                  color: DSColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimingCard(
                  icon: Icons.today,
                  label: '최적의 달',
                  value: bestMonth,
                  color: DSColors.accentSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 이유
          Text(
            timingReason,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 시기 카드
class _TimingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TimingCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: DSTypography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 속궁합 분석 섹션
class IntimateCompatibilitySection extends StatelessWidget {
  final Map<String, dynamic>? intimateCompatibility;

  const IntimateCompatibilitySection({super.key, required this.intimateCompatibility});

  @override
  Widget build(BuildContext context) {
    if (intimateCompatibility == null) return const SizedBox.shrink();

    final colors = context.colors;
    final passionScore = intimateCompatibility!['passion_score'] as num? ?? 0;
    final chemistryType = intimateCompatibility!['chemistry_type'] as String? ?? '';
    final emotionalConnection = intimateCompatibility!['emotional_connection'] as String? ?? '';
    final physicalHarmony = intimateCompatibility!['physical_harmony'] as String? ?? '';
    final intimateAdvice = intimateCompatibility!['intimate_advice'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withValues(alpha: 0.1),
            const Color(0xFF9C27B0).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: const Color(0xFFE91E63).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 20),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '속궁합 분석',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              // 열정 점수
              _PassionScoreGauge(score: passionScore.toInt()),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 케미스트리 유형
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: const Color(0xFFE91E63)),
                const SizedBox(width: 4),
                Text(
                  chemistryType,
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // 정서적 교감
          _IntimateCard(
            icon: Icons.psychology,
            title: '정서적 교감',
            content: emotionalConnection,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: DSSpacing.md),

          // 에너지 조화
          _IntimateCard(
            icon: Icons.whatshot,
            title: '에너지 조화',
            content: physicalHarmony,
            color: const Color(0xFFE91E63),
          ),
          const SizedBox(height: DSSpacing.md),

          // 관계 조언
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFFE91E63),
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '더 깊은 유대를 위한 조언',
                        style: DSTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intimateAdvice,
                        style: DSTypography.bodySmall.copyWith(
                          height: 1.6,
                          color: colors.textSecondary,
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
}

/// 열정 점수 게이지
class _PassionScoreGauge extends StatelessWidget {
  final int score;

  const _PassionScoreGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            final filled = index < (score / 2).ceil();
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: filled
                    ? const Color(0xFFE91E63)
                    : const Color(0xFFE91E63).withValues(alpha: 0.3),
              ),
            );
          }),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: DSTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }
}

/// 속궁합 내부 카드
class _IntimateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _IntimateCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            content,
            style: DSTypography.bodySmall.copyWith(
              height: 1.7,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
