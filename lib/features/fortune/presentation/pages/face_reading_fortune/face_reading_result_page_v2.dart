import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../domain/models/face_reading_result_v2.dart';
import '../../../domain/models/face_condition.dart';
import '../../../domain/models/emotion_analysis.dart';
import '../../widgets/face_reading/celebrity_match_carousel.dart';
import 'widgets/key_points_summary_card.dart';
import 'widgets/myeonggung_detail_card.dart';
import 'widgets/migan_detail_card.dart';
import 'widgets/face_condition_card.dart';
import 'widgets/emotion_recognition_card.dart';
import 'widgets/today_face_condition_widget.dart';
import 'widgets/expandable_section_card.dart';
import 'widgets/relationship_impression_card.dart';

/// 관상운세 결과 페이지 V2 - 리디자인된 관상 분석
/// 핵심 가치: 자기계발 ❌ → 위로·공감·공유 ✅
/// 타겟: 2-30대 여성
class FaceReadingResultPageV2 extends ConsumerStatefulWidget {
  /// 관상 분석 결과 데이터 (V2)
  final FaceReadingResultV2 result;

  /// 잠금 해제 요청 콜백
  final VoidCallback? onUnlockRequested;

  /// 업로드된 이미지 파일
  final File? uploadedImageFile;

  /// 사용자 성별 (콘텐츠 차별화)
  final String? gender;

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션들
  final List<String>? blurredSections;

  const FaceReadingResultPageV2({
    super.key,
    required this.result,
    this.onUnlockRequested,
    this.uploadedImageFile,
    this.gender,
    this.isBlurred = false,
    this.blurredSections,
  });

  @override
  ConsumerState<FaceReadingResultPageV2> createState() =>
      _FaceReadingResultPageV2State();
}

class _FaceReadingResultPageV2State
    extends ConsumerState<FaceReadingResultPageV2> {
  final ScrollController _scrollController = ScrollController();
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();

    // 관상 분석 결과 공개 햅틱 (신비로운 공개)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hapticTriggered) {
        _hapticTriggered = true;
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? DSColors.backgroundDark : DSColors.background,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 오늘의 안색 한줄 인사이트 (최상단)
            if (widget.result.faceCondition != null ||
                widget.result.emotionAnalysis != null)
              TodayFaceConditionWidget(
                condition: widget.result.faceCondition,
                emotionAnalysis: widget.result.emotionAnalysis,
                gender: widget.gender,
                isDark: isDark,
              ),

            const SizedBox(height: 16),

            // 2. 상단 헤더: 업로드 이미지 + 관상 맵
            UnifiedBlurWrapper(
              isBlurred: widget.isBlurred,
              blurredSections: widget.blurredSections ?? [],
              sectionKey: 'face_header',
              child: _buildHeaderCard(context, isDark),
            ),

            const SizedBox(height: 20),

            // 3. 핵심 포인트 요약 (항상 펼침)
            if (widget.result.priorityInsights.isNotEmpty)
              KeyPointsSummaryCard(
                insights: widget.result.priorityInsights,
                isDark: isDark,
                gender: widget.gender,
              ),

            const SizedBox(height: 16),

            // 4. 오늘의 안색 상세 (컨디션 카드)
            if (widget.result.faceCondition != null) ...[
              FaceConditionCard(
                condition: widget.result.faceCondition!,
                isDark: isDark,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                onUnlockRequested: widget.onUnlockRequested,
              ),
              const SizedBox(height: 16),
            ],

            // 5. 감정 인식 카드
            if (widget.result.emotionAnalysis != null) ...[
              EmotionRecognitionCard(
                emotionAnalysis: widget.result.emotionAnalysis!,
                isDark: isDark,
                gender: widget.gender,
              ),
              const SizedBox(height: 16),
            ],

            // 5.5. 관계 인상 분석 (프리미엄) - 다른 사람에게 어떻게 보이는지
            if (widget.result.emotionAnalysis?.impressionAnalysis != null) ...[
              RelationshipImpressionCard(
                impressionAnalysis: widget.result.emotionAnalysis!.impressionAnalysis,
                isDark: isDark,
                gender: widget.gender,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                onUnlockRequested: widget.onUnlockRequested,
                initiallyExpanded: false,
              ),
              const SizedBox(height: 16),
            ],

            // 6. 닮은꼴 연예인 (있는 경우)
            if (widget.result.celebrityMatches.isNotEmpty) ...[
              CelebrityMatchCarousel(
                celebrities: widget.result.celebrityMatches
                    .map((c) => c.toJson())
                    .toList(),
                isBlurred: widget.isBlurred,
              ),
              const SizedBox(height: 20),
            ],

            // 7. 명궁 상세 분석 (기본 접힘)
            if (widget.result.myeonggungAnalysis != null) ...[
              MyeonggungDetailCard(
                analysis: widget.result.myeonggungAnalysis!,
                isDark: isDark,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                initiallyExpanded: false,
                onUnlockRequested: widget.onUnlockRequested,
                gender: widget.gender,
              ),
              const SizedBox(height: 12),
            ],

            // 8. 미간 상세 분석 (기본 접힘)
            if (widget.result.miganAnalysis != null) ...[
              MiganDetailCard(
                analysis: widget.result.miganAnalysis!,
                isDark: isDark,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                initiallyExpanded: false,
                onUnlockRequested: widget.onUnlockRequested,
                gender: widget.gender,
              ),
              const SizedBox(height: 16),
            ],

            // 9. 오관(五官) 요약 섹션 (접이식)
            if (widget.result.simplifiedOgwan != null) ...[
              ExpandableSectionCard(
                title: '오관 분석',
                subtitle: '5가지 감각 기관으로 보는 당신의 매력 (五官)',
                summary: widget.result.simplifiedOgwan!.summary,
                detailContent: _buildOgwanDetailContent(
                    widget.result.simplifiedOgwan!, isDark),
                icon: Icons.face_retouching_natural,
                color: DSColors.accent,
                isDark: isDark,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                sectionKey: 'ogwan',
                initiallyExpanded: false,
                onUnlockRequested: widget.onUnlockRequested,
              ),
              const SizedBox(height: 12),
            ],

            // 10. 십이궁(十二宮) 요약 섹션 (접이식)
            if (widget.result.simplifiedSibigung != null) ...[
              ExpandableSectionCard(
                title: '십이궁 분석',
                subtitle: '12가지 운세 영역으로 보는 인생 지도 (十二宮)',
                summary: widget.result.simplifiedSibigung!.summary,
                detailContent: _buildSibigungDetailContent(
                    widget.result.simplifiedSibigung!, isDark),
                icon: Icons.auto_awesome,
                color: DSColors.accentTertiary,
                isDark: isDark,
                isBlurred: widget.isBlurred,
                blurredSections: widget.blurredSections,
                sectionKey: 'sibigung',
                initiallyExpanded: false,
                onUnlockRequested: widget.onUnlockRequested,
              ),
              const SizedBox(height: 16),
            ],

            // 11. 성별 특화 섹션들
            ..._buildGenderSpecificSections(context, isDark),

            // 하단 여백
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더 카드 (이미지 + 점수)
  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    final faceType = widget.result.faceType;
    final overallScore = widget.result.overallScore;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.surfaceDark
            : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? DSColors.borderDark
              : DSColors.border,
        ),
      ),
      child: Column(
        children: [
          // 두 이미지 나란히
          Row(
            children: [
              // 업로드한 얼굴 이미지
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.uploadedImageFile != null
                        ? Image.file(
                            widget.uploadedImageFile!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isDark
                                ? DSColors.backgroundSecondaryDark
                                : DSColors.backgroundSecondary,
                            child: Icon(
                              Icons.face,
                              size: 48,
                              color: isDark
                                  ? DSColors.textSecondaryDark
                                  : DSColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 관상 맵 이미지
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/face_reading/face_map_korean.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark
                              ? DSColors.backgroundSecondaryDark
                              : DSColors.backgroundSecondary,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face_retouching_natural,
                                size: 40,
                                color: isDark
                                    ? DSColors.textSecondaryDark
                                    : DSColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '관상 맵',
                                style: context.labelSmall.copyWith(
                                  color: isDark
                                      ? DSColors.textSecondaryDark
                                      : DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 얼굴형 + 점수 + 친근한 메시지
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faceType,
                      style: context.heading2.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGreetingMessage(),
                      style: context.labelSmall.copyWith(
                        color: isDark
                            ? DSColors.textSecondaryDark
                            : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildScoreBadge(context, overallScore, isDark),
            ],
          ),

          const SizedBox(height: 12),

          // 점수 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallScore / 100,
              backgroundColor: isDark
                  ? DSColors.backgroundSecondaryDark
                  : DSColors.backgroundSecondary,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getScoreColor(overallScore)),
              minHeight: 6,
            ),
          ),

          // 총평 (친근한 말투)
          if (widget.result.overallFortune.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DSColors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DSColors.accent.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: DSColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.result.overallFortune,
                      style: context.bodyMedium.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        height: 1.6,
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
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 점수 뱃지
  Widget _buildScoreBadge(BuildContext context, int score, bool isDark) {
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$score점',
        style: context.heading3.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 성별에 따른 인사 메시지
  String _getGreetingMessage() {
    if (widget.gender == 'female') {
      return '오늘도 빛나는 당신의 관상이에요 ✨';
    } else if (widget.gender == 'male') {
      return '오늘 당신의 관상 분석 결과예요';
    }
    return '관상 분석 결과를 확인해 보세요';
  }

  /// 점수에 따른 색상
  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accentTertiary;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  /// 성별 특화 섹션들
  List<Widget> _buildGenderSpecificSections(BuildContext context, bool isDark) {
    final sections = <Widget>[];

    // 여성 전용: 메이크업 추천
    if (widget.gender == 'female' &&
        widget.result.makeupRecommendations != null) {
      sections.add(_buildMakeupRecommendationSection(context, isDark));
      sections.add(const SizedBox(height: 16));
    }

    // 여성 전용: 연애/결혼운
    if (widget.gender == 'female') {
      sections.addAll(_buildFemaleFortunesSections(context, isDark));
    }

    // 남성 전용: 직업/리더십
    if (widget.gender == 'male') {
      sections.addAll(_buildMaleFortunesSections(context, isDark));
    }

    return sections;
  }

  /// 메이크업 추천 섹션 (여성 전용)
  Widget _buildMakeupRecommendationSection(BuildContext context, bool isDark) {
    final makeup = widget.result.makeupRecommendations!;

    return UnifiedBlurWrapper(
      isBlurred: widget.isBlurred,
      blurredSections: widget.blurredSections ?? [],
      sectionKey: 'makeup_recommendations',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.withValues(alpha: 0.08),
              Colors.purple.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.pink.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.brush,
                    color: Colors.pink,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '매력 포인트 메이크업',
                        style: context.heading3.copyWith(
                          color: isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '당신의 강점을 살리는 스타일 팁',
                        style: context.labelSmall.copyWith(
                          color: isDark
                              ? DSColors.textSecondaryDark
                              : DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 강점 부위
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.pink.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.pink,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '가장 매력적인 포인트: ${makeup.mostAttractiveFeature}',
                      style: context.bodyMedium.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 강조 팁
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.purple.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.purple,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      makeup.enhancementTip,
                      style: context.bodyMedium.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 추천 스타일들
            if (makeup.recommendedStyles.isNotEmpty) ...[
              Text(
                '추천 스타일',
                style: context.labelLarge.copyWith(
                  color: Colors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...makeup.recommendedStyles.map((style) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(style.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style.styleName,
                                style: context.bodyMedium.copyWith(
                                  color: isDark
                                      ? DSColors.textPrimaryDark
                                      : DSColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${style.description} (${style.suitableOccasion})',
                                style: context.bodySmall.copyWith(
                                  color: isDark
                                      ? DSColors.textSecondaryDark
                                      : DSColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  /// 여성용 운세 섹션들
  List<Widget> _buildFemaleFortunesSections(BuildContext context, bool isDark) {
    return [
      // 연애운, 결혼운, 면접 인상 등 추후 확장
    ];
  }

  /// 남성용 운세 섹션들
  List<Widget> _buildMaleFortunesSections(BuildContext context, bool isDark) {
    return [
      // 직업운, 리더십, 건강운 등 추후 확장
    ];
  }

  /// 오관 상세 콘텐츠 빌더
  Widget _buildOgwanDetailContent(SimplifiedOgwan ogwan, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 가장 좋은 부위
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: DSColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: DSColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '가장 좋은 부위: ${ogwan.bestFeature}',
                  style: context.bodyMedium.copyWith(
                    color: DSColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 주의 부위 (있는 경우)
        if (ogwan.cautionFeature != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: DSColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '주의할 부위: ${ogwan.cautionFeature}',
                    style: context.bodyMedium.copyWith(
                      color: DSColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // 개별 항목들
        ...ogwan.items.map((item) => SimplifiedAnalysisItem(
              name: item.featureName,
              summary: item.summary,
              score: item.score,
              icon: _getOgwanIcon(item.featureId),
              color: DSColors.accent,
              isDark: isDark,
            )),
      ],
    );
  }

  /// 십이궁 상세 콘텐츠 빌더
  Widget _buildSibigungDetailContent(SimplifiedSibigung sibigung, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 가장 강한 궁
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: DSColors.accentTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: DSColors.accentTertiary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '가장 강한 궁: ${sibigung.strongestPalace}',
                  style: context.bodyMedium.copyWith(
                    color: DSColors.accentTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 주의 궁 (있는 경우)
        if (sibigung.cautionPalace != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: DSColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '주의할 궁: ${sibigung.cautionPalace}',
                    style: context.bodyMedium.copyWith(
                      color: DSColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // 개별 항목들
        ...sibigung.items.map((item) => SimplifiedAnalysisItem(
              name: item.palaceName,
              summary: item.summary,
              score: item.score,
              icon: Icons.brightness_1,
              color: DSColors.accentTertiary,
              isDark: isDark,
            )),
      ],
    );
  }

  /// 오관 아이콘 매핑
  IconData _getOgwanIcon(String featureId) {
    switch (featureId) {
      case 'eyes':
        return Icons.visibility;
      case 'nose':
        return Icons.air;
      case 'mouth':
        return Icons.mic;
      case 'ears':
        return Icons.hearing;
      case 'eyebrows':
        return Icons.face;
      default:
        return Icons.circle;
    }
  }
}
