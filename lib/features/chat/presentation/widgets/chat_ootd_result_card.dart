import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/infographic/headers/ootd_info_header.dart';
import '../../../../core/constants/fortune_card_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OOTD 평가 결과 카드 - 패션 매거진 스타일
///
/// AI가 평가한 OOTD 결과를 비주얼 분석 보고서 형태로 표시합니다.
/// - 점수 + 등급 + 원형 게이지
/// - 해시태그 칩
/// - 6각형 레이더 차트
/// - 스타일 처방전
/// - 셀럽 + 추천 아이템 2열 카드
class ChatOotdResultCard extends ConsumerWidget {
  final Map<String, dynamic> ootdData;
  final bool isBlurred;
  final List<String> blurredSections;

  const ChatOotdResultCard({
    super.key,
    required this.ootdData,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  // 동양화 스타일 - 포인트 색상은 쪽빛(cheongMuted) 사용
  static Color _getAccentColor(BuildContext context) => ObangseokColors.cheongMuted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.hanji(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인포그래픽 헤더 (점수, 등급, 레이더, 해시태그 통합)
            _buildInfoHeader(context),
            UnifiedBlurWrapper(
              isBlurred: isBlurred,
              blurredSections: blurredSections,
              sectionKey: 'ootd-result',
              fortuneType: 'ootd-evaluation',
              child: Column(
                children: [
                  _buildPrescriptionSection(context),
                  _buildBottomCardsSection(context),
                  const SizedBox(height: DSSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 인포그래픽 헤더 (점수, 등급, 레이더 차트, 해시태그 통합)
  Widget _buildInfoHeader(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final score = (ootdData['score'] as num?)?.toInt() ?? 75;
    final grade = details['overallGrade'] as String? ?? 'C';

    // 레이더 데이터 추출
    Map<String, dynamic>? radarScores;
    final analysis = details['detailedAnalysis'] as Map<String, dynamic>?;
    if (analysis != null) {
      radarScores = {};
      for (final entry in analysis.entries) {
        if (entry.value is Map) {
          final scoreVal = (entry.value as Map)['score'];
          if (scoreVal != null) {
            radarScores[entry.key] = scoreVal;
          }
        }
      }
    }

    // 해시태그 추출
    final hashtags = (details['hashtags'] as List?)?.cast<String>() ??
        (ootdData['keywords'] as List?)?.cast<String>() ??
        [];

    return Stack(
      children: [
        // 인포그래픽 헤더
        OotdInfoHeader(
          score: score,
          grade: grade,
          radarScores: radarScores,
          hashtags: hashtags,
        ),
        // 액션 버튼 오버레이
        Positioned(
          top: DSSpacing.sm,
          right: DSSpacing.sm,
          child: FortuneActionButtons(
            contentId: ootdData['id']?.toString() ??
                'ootd_${DateTime.now().millisecondsSinceEpoch}',
            contentType: 'ootd',
            shareTitle: 'OOTD 평가 결과',
            shareContent: ootdData['overallAdvice'] ?? '패션 분석 결과입니다.',
            iconSize: 20,
            iconColor: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 스타일 처방전 섹션
  Widget _buildPrescriptionSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final suggestions =
        (details['softSuggestions'] as List<dynamic>?)?.cast<String>() ?? [];

    if (suggestions.isEmpty) return const SizedBox.shrink();

    // 아이콘 매핑 (제안 내용에 따라)
    final icons = ['🧴', '✨', '💍', '👗', '👠'];

    return Container(
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
                FortuneCardImages.getSectionIcon('fashion'),
                width: 32,
                height: 32,
              ),
              const SizedBox(width: DSSpacing.md),
              Text(
                '이렇게 하면 더 완벽해요!',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final icon = icons[index % icons.length];

            // 마지막 항목은 하이라이트 박스로 표시
            if (index == suggestions.length - 1 && suggestions.length > 1) {
              return Container(
                margin: const EdgeInsets.only(top: DSSpacing.xs),
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: _getAccentColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border: Border.all(
                    color: _getAccentColor(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: _buildHighlightedText(suggestion, context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: context.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  /// 하이라이트 텍스트 빌더 (+20% 등을 강조)
  List<TextSpan> _buildHighlightedText(String text, BuildContext context) {
    final colors = context.colors;
    final regex = RegExp(r'(\+\d+%[^\s]*)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: context.bodyMedium.copyWith(color: colors.textPrimary),
        ),
      ];
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: context.bodyMedium.copyWith(color: colors.textPrimary),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: context.bodyMedium.copyWith(
          color: _getAccentColor(context),
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: context.bodyMedium.copyWith(color: colors.textPrimary),
      ));
    }

    return spans;
  }

  /// 하단 2열 카드 섹션 (셀럽 + 추천 아이템)
  Widget _buildBottomCardsSection(BuildContext context) {
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final celebMatch = details['celebrityMatch'] as Map<String, dynamic>?;
    final items = (details['recommendedItems'] as List<dynamic>?) ?? [];

    // 둘 다 없으면 표시 안 함
    if (celebMatch == null && items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 셀럽 스타일 매칭 카드
          if (celebMatch != null)
            Expanded(
              child: _buildCelebCard(context, celebMatch),
            ),
          if (celebMatch != null && items.isNotEmpty)
            const SizedBox(width: DSSpacing.sm),
          // 추천 아이템 카드
          if (items.isNotEmpty)
            Expanded(
              child: _buildRecommendCard(
                  context, items.first as Map<String, dynamic>),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  /// 셀럽 스타일 매칭 카드
  Widget _buildCelebCard(
      BuildContext context, Map<String, dynamic> celebMatch) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = celebMatch['name'] as String? ?? '';
    final similarity = (celebMatch['similarity'] as num?)?.toInt() ?? 0;
    final reason = celebMatch['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
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
              Image.asset(
                FortuneCardImages.getSectionIcon('lucky'),
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '셀럽 스타일 매칭',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 프로필 원형
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ObangseokColors.getMeok(context).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '$name의',
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '"${_getStyleConcept(name)}" 무드',
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
          Text(
            '$similarity% 일치',
            style: context.labelSmall.copyWith(
              color: ObangseokColors.getMeok(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            reason,
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 셀럽별 스타일 컨셉 (예시)
  String _getStyleConcept(String name) {
    final concepts = {
      '아이유': 'LILAC',
      '블랙핑크': 'PINK VENOM',
      '방탄소년단': 'DYNAMITE',
      '뉴진스': 'DITTO',
      '에스파': 'NEXT LEVEL',
    };
    for (final entry in concepts.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 'ICONIC';
  }

  /// 추천 아이템 카드
  Widget _buildRecommendCard(BuildContext context, Map<String, dynamic> item) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = item['emoji'] as String? ?? '👗';
    final itemName = item['item'] as String? ?? '';
    final reason = item['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
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
              Image.asset(
                FortuneCardImages.getSectionIcon('lucky'),
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '추천 아이템',
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 아이템 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getAccentColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            itemName,
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            reason,
            style: context.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DSSpacing.sm),
          // 스타일링 팁 확인 버튼
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
            decoration: BoxDecoration(
              color: _getAccentColor(context),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Text(
              '스타일링 팁 확인',
              style: context.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
