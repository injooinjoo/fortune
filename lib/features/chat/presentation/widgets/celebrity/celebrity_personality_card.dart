import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../shared/widgets/smart_image.dart';

/// 유명인 성격궁합 전용 카드
///
/// API 응답 필드:
/// - saju_analysis (오행, 일주, 합 분석)
/// - past_life (전생 인연)
/// - destined_timing (운명의 시기)
/// - intimate_compatibility (속궁합)
/// - detailed_analysis (상세 분석)
/// - strengths, challenges, recommendations
/// - lucky_factors, special_message
class CelebrityPersonalityCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String? celebrityName;
  final String? celebrityImageUrl;

  const CelebrityPersonalityCard({
    super.key,
    required this.fortune,
    this.celebrityName,
    this.celebrityImageUrl,
  });

  @override
  ConsumerState<CelebrityPersonalityCard> createState() =>
      _CelebrityPersonalityCardState();
}

class _CelebrityPersonalityCardState
    extends ConsumerState<CelebrityPersonalityCard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  // 데이터 추출 헬퍼 - API 필드명과 일치
  Map<String, dynamic> get _additionalInfo =>
      widget.fortune.additionalInfo ?? {};

  // 사주 분석 (오행, 일주, 합)
  Map<String, dynamic>? get _sajuAnalysis =>
      _additionalInfo['saju_analysis'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _fiveElements =>
      _sajuAnalysis?['five_elements'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _dayPillar =>
      _sajuAnalysis?['day_pillar'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _hapAnalysis =>
      _sajuAnalysis?['hap_analysis'] as Map<String, dynamic>?;

  // 전생 인연
  Map<String, dynamic>? get _pastLife =>
      _additionalInfo['past_life'] as Map<String, dynamic>?;

  // 운명의 시기
  Map<String, dynamic>? get _destinedTiming =>
      _additionalInfo['destined_timing'] as Map<String, dynamic>?;

  // 속궁합
  Map<String, dynamic>? get _intimateCompatibility =>
      _additionalInfo['intimate_compatibility'] as Map<String, dynamic>?;

  // 상세 분석
  Map<String, dynamic>? get _detailedAnalysis =>
      _additionalInfo['detailed_analysis'] as Map<String, dynamic>?;

  // 리스트 데이터
  List<dynamic>? get _strengths =>
      _additionalInfo['strengths'] as List<dynamic>?;

  List<dynamic>? get _challenges =>
      _additionalInfo['challenges'] as List<dynamic>?;

  List<dynamic>? get _recommendations =>
      _additionalInfo['recommendations'] as List<dynamic>?;

  // 행운 요소
  Map<String, dynamic>? get _luckyFactors =>
      _additionalInfo['lucky_factors'] as Map<String, dynamic>?;

  // 특별 메시지
  String? get _specialMessage =>
      _additionalInfo['special_message'] as String?;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

          // 1. 오행 분석
          if (_fiveElements != null)
            _buildFiveElementsSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

          // 2. 일주 궁합
          if (_dayPillar != null)
            _buildDayPillarSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms),

          // 3. 합 분석
          if (_hapAnalysis != null)
            _buildHapAnalysisSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          // 4. 전생 인연
          if (_pastLife != null)
            _buildPastLifeSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

          // 5. 운명의 시기
          if (_destinedTiming != null)
            _buildDestinedTimingSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),

          // 6. 속궁합 분석
          if (_intimateCompatibility != null)
            _buildIntimateSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms),

          // 7. 상세 분석
          if (_detailedAnalysis != null)
            _buildDetailedAnalysisSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 800.ms),

          // 8. 강점
          if (_strengths != null && _strengths!.isNotEmpty)
            _buildStrengthsSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 900.ms),

          // 9. 도전과제
          if (_challenges != null && _challenges!.isNotEmpty)
            _buildChallengesSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 1000.ms),

          // 10. 조언
          if (_recommendations != null && _recommendations!.isNotEmpty)
            _buildRecommendationsSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 1100.ms),

          // 11. 행운 요소
          if (_luckyFactors != null)
            _buildLuckyFactorsSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 1200.ms),

          // 12. 특별 메시지
          if (_specialMessage != null && _specialMessage!.isNotEmpty)
            _buildSpecialMessageSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 1300.ms),

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
            DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.15),
            DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // 유명인 아바타
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.2),
              border: Border.all(
                color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.4),
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
          const SizedBox(width: DSSpacing.md),

          // 이름 + 타입
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.celebrityName ?? '유명인'}과의 궁합',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🔮 사주 & 전생 인연 분석',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수 배지
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getScoreColor(score),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: typography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '점',
                  style: typography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
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
          color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.1),
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

  // 1. 오행 분석
  Widget _buildFiveElementsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _fiveElements!;

    return _buildSection(
      context,
      icon: '🔥',
      title: '오행 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildElementBadge(data['user_dominant'] ?? '', context),
              const SizedBox(width: DSSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                child: Text(
                  data['interaction'] ?? '',
                  style: typography.labelSmall.copyWith(
                    color: _getInteractionColor(data['interaction']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              _buildElementBadge(data['celebrity_dominant'] ?? '', context),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['interpretation'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 2. 일주 궁합
  Widget _buildDayPillarSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _dayPillar!;

    return _buildSection(
      context,
      icon: '📅',
      title: '일주 궁합',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['relationship'] != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryLotto.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                data['relationship'],
                style: typography.labelSmall.copyWith(
                  color: DSFortuneColors.categoryLotto,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['interpretation'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. 합 분석
  Widget _buildHapAnalysisSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _hapAnalysis!;
    final hasHap = data['has_hap'] == true;

    return _buildSection(
      context,
      icon: hasHap ? '💫' : '🔗',
      title: '합(合) 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: hasHap
                      ? colors.success.withValues(alpha: 0.1)
                      : colors.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(
                  hasHap ? '${data['hap_type'] ?? '합'} 발견!' : '합 없음',
                  style: typography.labelSmall.copyWith(
                    color: hasHap
                        ? colors.success
                        : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['interpretation'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 4. 전생 인연
  Widget _buildPastLifeSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _pastLife!;
    final evidence = data['evidence'] as List? ?? [];

    return _buildSection(
      context,
      icon: '🌙',
      title: '전생 인연',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['connection_type'] != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                data['connection_type'],
                style: typography.labelSmall.copyWith(
                  color: DSFortuneColors.categoryLuckyItems,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['story'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryLuckyItems.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ 사주에서 발견된 증거',
                    style: typography.labelSmall.copyWith(
                      color: DSFortuneColors.categoryLuckyItems,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  ...evidence.take(3).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $e',
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. 운명의 시기
  Widget _buildDestinedTimingSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _destinedTiming!;

    return _buildSection(
      context,
      icon: '⏰',
      title: '운명의 시기',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: [
              if (data['best_year'] != null)
                _buildTimingBadge(data['best_year'], DSFortuneColors.categoryLove, context),
              if (data['best_month'] != null)
                _buildTimingBadge(data['best_month'], DSFortuneColors.categoryExercise, context),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            data['timing_reason'] ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingBadge(String text, Color color, BuildContext context) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Text(
        text,
        style: typography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 6. 속궁합 분석
  Widget _buildIntimateSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _intimateCompatibility!;
    final passionScore = (data['passion_score'] as num?)?.toInt() ?? 5;

    return _buildSection(
      context,
      icon: '💕',
      title: '에너지 케미',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 열정 점수
          Row(
            children: [
              Text(
                '열정도',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              ...List.generate(10, (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  i < passionScore ? Icons.favorite : Icons.favorite_border,
                  size: 14,
                  color: i < passionScore
                      ? DSFortuneColors.categoryLove
                      : colors.textSecondary.withValues(alpha: 0.3),
                ),
              )),
            ],
          ),
          if (data['chemistry_type'] != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryLove.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                data['chemistry_type'],
                style: typography.labelSmall.copyWith(
                  color: DSFortuneColors.categoryLove,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (data['emotional_connection'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              data['emotional_connection'],
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (data['physical_harmony'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              data['physical_harmony'],
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (data['intimate_advice'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSFortuneColors.categoryGratitude.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['intimate_advice'],
                      style: typography.labelSmall.copyWith(
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

  // 7. 상세 분석
  Widget _buildDetailedAnalysisSection(BuildContext context) {
    final data = _detailedAnalysis!;

    return _buildSection(
      context,
      icon: '📊',
      title: '상세 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['personality_match'] != null)
            _buildAnalysisCard(
              context,
              '성격 궁합',
              data['personality_match'],
              DSFortuneColors.categoryFamily,
            ),
          if (data['energy_compatibility'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildAnalysisCard(
              context,
              '에너지 궁합',
              data['energy_compatibility'],
              DSFortuneColors.categoryMoney,
            ),
          ],
          if (data['life_path_connection'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildAnalysisCard(
              context,
              '인생 경로 연결',
              data['life_path_connection'],
              DSFortuneColors.categoryLuckyItems,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, String title, String content, Color color) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            content,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 8. 강점
  Widget _buildStrengthsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return _buildSection(
      context,
      icon: '💪',
      title: '강점',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _strengths!.take(4).map((strength) => Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅'),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  strength.toString(),
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // 9. 도전과제
  Widget _buildChallengesSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return _buildSection(
      context,
      icon: '⚡',
      title: '도전과제',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _challenges!.take(3).map((challenge) => Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️'),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  challenge.toString(),
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // 10. 조언
  Widget _buildRecommendationsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return _buildSection(
      context,
      icon: '💡',
      title: '조언',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _recommendations!.take(4).map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌟'),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  rec.toString(),
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // 11. 행운 요소
  Widget _buildLuckyFactorsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _luckyFactors!;

    final items = <MapEntry<String, String>>[];
    if (data['best_time_to_connect'] != null) {
      items.add(MapEntry('🕐 최적 시간', data['best_time_to_connect']));
    }
    if (data['lucky_activity'] != null) {
      items.add(MapEntry('🎯 추천 활동', data['lucky_activity']));
    }
    if (data['shared_interest'] != null) {
      items.add(MapEntry('🤝 공유 관심사', data['shared_interest']));
    }
    if (data['lucky_color'] != null) {
      items.add(MapEntry('🎨 행운의 색', data['lucky_color']));
    }
    if (data['lucky_direction'] != null) {
      items.add(MapEntry('🧭 행운의 방향', data['lucky_direction']));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      context,
      icon: '🍀',
      title: '행운 요소',
      child: Wrap(
        spacing: DSSpacing.sm,
        runSpacing: DSSpacing.sm,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: DSFortuneColors.categoryMoney.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.key,
                style: typography.labelSmall.copyWith(
                  color: DSFortuneColors.categoryMoney,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              Text(
                item.value,
                style: typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // 12. 특별 메시지
  Widget _buildSpecialMessageSection(BuildContext context) {
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.1),
              DSFortuneColors.categoryLove.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💌', style: TextStyle(fontSize: 18)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '특별 메시지',
                  style: typography.labelLarge.copyWith(
                    color: DSFortuneColors.categoryPersonalityDna,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              _specialMessage!,
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementBadge(String element, BuildContext context) {
    final typography = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
      decoration: BoxDecoration(
        gradient: _getElementGradient(element),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Text(
        element,
        style: typography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: DSFortuneColors.categoryPersonalityDna.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return DSFortuneColors.categoryLove;
    if (score >= 80) return DSFortuneColors.categoryExercise;
    if (score >= 70) return DSFortuneColors.categoryLotto;
    return DSFortuneColors.categoryExLover;
  }

  Color _getInteractionColor(String? interaction) {
    switch (interaction) {
      case '상생':
        return DSFortuneColors.categoryMoney;
      case '상극':
        return DSFortuneColors.categoryNewYear;
      default:
        return DSFortuneColors.categoryExLover;
    }
  }

  LinearGradient _getElementGradient(String element) {
    if (element.contains('木') || element.contains('목')) {
      return LinearGradient(colors: [DSFortuneColors.elementWood, DSFortuneColors.elementWood.withValues(alpha: 0.8)]);
    }
    if (element.contains('火') || element.contains('화')) {
      return LinearGradient(colors: [DSFortuneColors.elementFire, DSFortuneColors.elementFire.withValues(alpha: 0.8)]);
    }
    if (element.contains('土') || element.contains('토')) {
      return LinearGradient(colors: [DSFortuneColors.elementEarth, DSFortuneColors.elementEarth.withValues(alpha: 0.8)]);
    }
    if (element.contains('金') || element.contains('금')) {
      return LinearGradient(colors: [DSFortuneColors.elementMetal, DSFortuneColors.elementMetal.withValues(alpha: 0.8)]);
    }
    if (element.contains('水') || element.contains('수')) {
      return LinearGradient(colors: [DSFortuneColors.elementWater, DSFortuneColors.elementWater.withValues(alpha: 0.8)]);
    }
    return LinearGradient(colors: [DSFortuneColors.categoryExLover, DSFortuneColors.categoryExLover.withValues(alpha: 0.8)]);
  }
}
