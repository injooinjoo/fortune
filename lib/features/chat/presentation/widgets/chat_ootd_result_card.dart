import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
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

  const ChatOotdResultCard({
    super.key,
    required this.ootdData,
  });

  // 동양화 스타일 - 포인트 색상은 쪽빛(cheongMuted) 사용
  static Color _getAccentColor(BuildContext context) => DSColors.info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.flat(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인포그래픽 헤더 (점수, 등급, 레이더, 해시태그 통합)
            _buildInfoHeader(context),
            // 전체 코멘트 (무료 공개)
            _buildOverallCommentSection(context),
            // 하이라이트 (무료 공개)
            _buildHighlightsSection(context),
            // TPO 피드백 (무료 공개)
            _buildTpoFeedbackSection(context),
            _buildPrescriptionSection(context),
            _buildBottomCardsSection(context),
            const SizedBox(height: DSSpacing.md),
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

    // 레이더 데이터 추출 - categories 필드 사용 (Edge Function 응답 구조에 맞춤)
    Map<String, dynamic>? radarScores;
    final categories = details['categories'] as Map<String, dynamic>?;
    if (categories != null && categories.isNotEmpty) {
      radarScores = {};
      // 6개 카테고리 한글 라벨로 변환
      const labelMap = {
        'colorHarmony': '색상조화',
        'silhouette': '실루엣',
        'styleConsistency': '스타일',
        'accessories': '액세서리',
        'tpoFit': 'TPO',
        'trendScore': '트렌드',
      };
      for (final entry in categories.entries) {
        num? scoreVal;

        // 다양한 응답 형식 처리
        if (entry.value is Map) {
          // 정상 형식: {score: 8.0, feedback: "..."}
          scoreVal = (entry.value as Map)['score'] as num?;
        } else if (entry.value is num) {
          // 간소화 형식: LLM이 숫자만 반환한 경우
          scoreVal = entry.value as num;
        } else if (entry.value is String) {
          // 문자열로 반환된 경우
          scoreVal = num.tryParse(entry.value as String);
        }

        if (scoreVal != null) {
          // 점수를 0-100 스케일로 변환 (원본은 0-10)
          final normalizedScore = scoreVal.toDouble() * 10;
          final label = labelMap[entry.key] ?? entry.key;
          radarScores[label] = normalizedScore;
        }
      }

      // 카테고리가 비어있으면 기본값으로 6개 축 생성
      if (radarScores.isEmpty) {
        radarScores = {
          '색상조화': 70.0,
          '실루엣': 70.0,
          '스타일': 70.0,
          '액세서리': 70.0,
          'TPO': 70.0,
          '트렌드': 70.0,
        };
      }
    } else {
      // categories가 null이면 score 기반으로 기본 레이더 데이터 생성
      final baseScore = (score / 10.0) * 10; // 0-100 스케일
      radarScores = {
        '색상조화': baseScore,
        '실루엣': baseScore,
        '스타일': baseScore,
        '액세서리': baseScore,
        'TPO': baseScore,
        '트렌드': baseScore,
      };
    }

    // 해시태그 추출 (styleKeywords도 fallback으로 사용)
    final hashtags = (details['hashtags'] as List?)?.cast<String>() ??
        (details['styleKeywords'] as List?)?.cast<String>() ??
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
            fortuneType: 'ootd-evaluation',
            shareTitle: 'OOTD 평가 결과',
            shareContent: ootdData['overallAdvice'] ?? '패션 분석 결과입니다.',
            iconSize: 20,
            iconColor: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 전체 코멘트 섹션 (무료 공개)
  Widget _buildOverallCommentSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final comment = details['overallComment'] as String? ??
        ootdData['content'] as String? ??
        '';

    if (comment.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💬', style: TextStyle(fontSize: 18)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              comment,
              style: context.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  /// 하이라이트 섹션 (잘된 포인트, 무료 공개)
  Widget _buildHighlightsSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final highlights =
        (details['highlights'] as List<dynamic>?)?.cast<String>() ?? [];

    if (highlights.isEmpty) return const SizedBox.shrink();

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
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '잘된 포인트',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          ...highlights.map((highlight) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•',
                        style:
                            context.bodyMedium.copyWith(color: colors.success)),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        highlight,
                        style: context.bodyMedium
                            .copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  /// TPO 피드백 섹션 (무료 공개)
  Widget _buildTpoFeedbackSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final tpo = details['tpo'] as String? ?? '';
    final tpoScore = (details['tpoScore'] as num?)?.toInt();
    final tpoFeedback = details['tpoFeedback'] as String? ?? '';

    if (tpoFeedback.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: _getAccentColor(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: _getAccentColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                'TPO 적합도',
                style: context.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (tpo.isNotEmpty) ...[
                const SizedBox(width: DSSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getAccentColor(context),
                    borderRadius: BorderRadius.circular(DSRadius.xs),
                  ),
                  child: Text(
                    tpo,
                    style: context.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (tpoScore != null) ...[
                const Spacer(),
                Text(
                  '$tpoScore점',
                  style: context.labelMedium.copyWith(
                    color: _getAccentColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            tpoFeedback,
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
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

  /// 하단 2열 카드 섹션 (셀럽 + 추천 아이템) - 반응형 레이아웃
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 너비가 좁으면 세로 배치, 넓으면 가로 배치
          final isNarrow = constraints.maxWidth < 320;

          final celebWidget =
              celebMatch != null ? _buildCelebCard(context, celebMatch) : null;
          final recommendWidget = items.isNotEmpty
              ? _buildRecommendCard(
                  context, items.first as Map<String, dynamic>)
              : null;

          if (isNarrow) {
            // 좁은 화면: 세로 배치
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (celebWidget != null) celebWidget,
                if (celebWidget != null && recommendWidget != null)
                  const SizedBox(height: DSSpacing.sm),
                if (recommendWidget != null) recommendWidget,
              ],
            );
          }

          // 넓은 화면: 가로 배치
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (celebWidget != null) Expanded(child: celebWidget),
              if (celebWidget != null && recommendWidget != null)
                const SizedBox(width: DSSpacing.sm),
              if (recommendWidget != null) Expanded(child: recommendWidget),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  /// 셀럽 스타일 매칭 카드
  Widget _buildCelebCard(
      BuildContext context, Map<String, dynamic> celebMatch) {
    final colors = context.colors;
    final name = celebMatch['name'] as String? ?? '';
    final similarity = (celebMatch['similarity'] as num?)?.toInt() ?? 0;
    final reason = celebMatch['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
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
              const SizedBox(width: DSSpacing.xs),
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
              color: DSColors.textPrimary.withValues(alpha: 0.2),
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
              color: DSColors.textPrimary,
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
    final emoji = item['emoji'] as String? ?? '👗';
    final itemName = item['item'] as String? ?? '';
    final reason = item['reason'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
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
              const SizedBox(width: DSSpacing.xs),
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
          GestureDetector(
            onTap: () => _showStylingTipSheet(context, itemName, reason, emoji),
            child: Container(
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
          ),
        ],
      ),
    );
  }

  /// 스타일링 팁 바텀시트 표시
  void _showStylingTipSheet(
    BuildContext context,
    String itemName,
    String reason,
    String emoji,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            // 헤더
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getAccentColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 아이템',
                        style: context.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        itemName,
                        style: context.heading4.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.lg),
            // 스타일링 팁 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: _getAccentColor(context).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: _getAccentColor(context).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        size: 18,
                        color: _getAccentColor(context),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Text(
                        '스타일링 팁',
                        style: context.bodyMedium.copyWith(
                          color: _getAccentColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    reason.isNotEmpty ? reason : '이 아이템으로 스타일을 완성해보세요!',
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
