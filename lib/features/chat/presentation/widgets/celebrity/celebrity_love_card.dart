import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../shared/widgets/smart_image.dart';

/// 유명인 연애궁합 전용 카드
///
/// 6개 상세 항목:
/// - 첫인상 분석
/// - 연애 케미
/// - 속궁합 분석
/// - 질투/독점욕
/// - 장기 연애 전망
/// - 결혼 궁합
class CelebrityLoveCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String? celebrityName;
  final String? celebrityImageUrl;

  const CelebrityLoveCard({
    super.key,
    required this.fortune,
    this.celebrityName,
    this.celebrityImageUrl,
  });

  @override
  ConsumerState<CelebrityLoveCard> createState() => _CelebrityLoveCardState();
}

class _CelebrityLoveCardState extends ConsumerState<CelebrityLoveCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  // 데이터 추출 헬퍼
  Map<String, dynamic> get _additionalInfo =>
      widget.fortune.additionalInfo ?? {};

  Map<String, dynamic>? get _firstImpression =>
      _additionalInfo['first_impression'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _romanceChemistry =>
      _additionalInfo['romance_chemistry'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _intimateCompatibility =>
      _additionalInfo['intimate_compatibility'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _jealousyAnalysis =>
      _additionalInfo['jealousy_analysis'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _longTermProspect =>
      _additionalInfo['long_term_prospect'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _marriageCompatibility =>
      _additionalInfo['marriage_compatibility'] as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          _buildHeader(context).animate().fadeIn(duration: 400.ms),

          // 메인 메시지
          _buildMainMessage(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),

          // 1. 첫인상 분석
          if (_firstImpression != null)
            _buildFirstImpressionSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

          // 2. 연애 케미
          if (_romanceChemistry != null)
            _buildRomanceChemistrySection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms),

          // 3. 속궁합 분석
          if (_intimateCompatibility != null)
            _buildIntimateSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          // 4. 질투/독점욕
          if (_jealousyAnalysis != null)
            _buildJealousySection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

          // 5. 장기 연애 전망
          if (_longTermProspect != null)
            _buildLongTermSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),

          // 6. 결혼 궁합
          if (_marriageCompatibility != null)
            _buildMarriageSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms),

          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = widget.fortune.score;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.error.withValues(alpha: 0.15), // 핑크 계열
            DSColors.error.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // 유명인 아바타 + 하트
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DSColors.error.withValues(alpha: 0.2),
                  border: Border.all(
                    color: DSColors.error.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.celebrityImageUrl != null
                      ? SmartImage(
                          path: widget.celebrityImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('💕', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(width: DSSpacing.md),

          // 이름 + 타입
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.celebrityName ?? '유명인'}과의 연애 궁합',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '💕 로맨틱 케미 분석',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수 배지 (하트 모양)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DSColors.error, DSColors.error],
              ),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Row(
              children: [
                const Text('💘', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: typography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMessage(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final message = widget.fortune.content;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: DSColors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: DSColors.error.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          message,
          style: typography.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildFirstImpressionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _firstImpression!;
    final score = data['score'] as num? ?? 0;

    return _buildSection(
      context,
      icon: '💘',
      title: '첫인상 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 점수 바
          Row(
            children: [
              Expanded(
                  child:
                      _buildHeartProgressBar(context, score.toDouble(), 100)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '${score.toInt()}점',
                style: typography.labelMedium.copyWith(
                  color: DSColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['description'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (data['chemistry_moment'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['chemistry_moment'],
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRomanceChemistrySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _romanceChemistry!;
    final passionLevel = data['passion_level'] as num? ?? 5;

    return _buildSection(
      context,
      icon: '🔥',
      title: '연애 케미',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 케미 타입 배지
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DSColors.warning, DSColors.error],
              ),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Text(
              data['type'] ?? '열정적인 케미',
              style: typography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 열정 레벨
          Row(
            children: [
              Text(
                '열정 레벨:',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              ...List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Text(
                    index < passionLevel ? '❤️' : '🤍',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['description'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntimateSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _intimateCompatibility!;

    return _buildSection(
      context,
      icon: '💕',
      title: '속궁합 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: DSColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: DSColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              data['chemistry_type'] ?? '',
              style: typography.labelSmall.copyWith(
                color: DSColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['emotional_connection'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (data['physical_harmony'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSColors.success.withValues(alpha: 0.05),
                    DSColors.error.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                data['physical_harmony'],
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJealousySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _jealousyAnalysis!;

    return _buildSection(
      context,
      icon: '💚',
      title: '질투/독점욕 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildJealousyCard(
                  context,
                  '나',
                  data['user_level'] ?? '',
                  DSColors.info,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildJealousyCard(
                  context,
                  widget.celebrityName ?? '상대',
                  data['celebrity_level'] ?? '',
                  DSColors.error,
                ),
              ),
            ],
          ),
          if (data['balance_tips'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💝'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['balance_tips'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJealousyCard(
      BuildContext context, String label, String level, Color color) {
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level,
            style: typography.bodySmall.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _longTermProspect!;
    final challenges = data['challenges'] as List? ?? [];

    return _buildSection(
      context,
      icon: '📅',
      title: '장기 연애 전망',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: DSColors.accentSecondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: DSColors.accentSecondary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗓️ 3년 후',
                  style: typography.labelSmall.copyWith(
                    color: DSColors.accentSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  data['three_year_forecast'] ?? '',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (data['excitement_maintenance'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✨'),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    data['excitement_maintenance'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (challenges.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            ...challenges.take(2).map((challenge) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          challenge.toString(),
                          style: typography.labelSmall.copyWith(
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

  Widget _buildMarriageSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _marriageCompatibility!;
    final score = data['score'] as num? ?? 0;

    return _buildSection(
      context,
      icon: '💍',
      title: '결혼 궁합',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 결혼 점수
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DSColors.warning.withValues(alpha: 0.2),
                  DSColors.success.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💒', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '결혼 궁합 ${score.toInt()}점',
                  style: typography.headingSmall.copyWith(
                    color: DSColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['family_harmony'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          if (data['lifestyle_match'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏠'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['lifestyle_match'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data['advice'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💝'),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    data['advice'],
                    style: typography.labelSmall.copyWith(
                      color: DSColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
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
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildHeartProgressBar(
      BuildContext context, double value, double max) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: DSColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / max).clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DSColors.error, DSColors.error],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: DSColors.error.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
