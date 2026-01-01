import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';

/// OOTD 평가 결과 카드
///
/// AI가 평가한 OOTD 결과를 표시합니다.
/// - 점수 + 등급 (S/A/B/C)
/// - TPO 적합도
/// - 칭찬 포인트
/// - 카테고리별 점수
/// - 부드러운 개선 제안
/// - 추천 아이템
/// - 셀럽 스타일 매칭 (선택)
class ChatOotdResultCard extends StatelessWidget {
  final Map<String, dynamic> ootdData;
  final bool isBlurred;
  final List<String> blurredSections;

  const ChatOotdResultCard({
    super.key,
    required this.ootdData,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: blurredSections,
            sectionKey: 'ootd-result',
            fortuneType: 'ootd-evaluation',
            child: Column(
              children: [
                _buildScoreSection(context),
                _buildHighlightsSection(context),
                _buildCategoryScoresSection(context),
                _buildSuggestionsSection(context),
                _buildRecommendedItemsSection(context),
                _buildCelebrityMatchSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final tpo = ootdData['tpo'] as String? ?? '';

    // TPO 라벨 매핑
    final tpoLabels = {
      'date': '💕 데이트',
      'interview': '💼 면접',
      'work': '🏢 출근',
      'casual': '☕ 일상',
      'party': '🎉 파티/모임',
      'wedding': '💒 경조사',
      'travel': '✈️ 여행',
      'sports': '🏃 운동',
    };

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF34D399), const Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: const Icon(
              Icons.checkroom,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OOTD 평가 결과',
                  style: context.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI Style Analysis',
                  style: context.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // TPO 뱃지
          if (tpo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Text(
                tpoLabels[tpo] ?? tpo,
                style: context.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final score = (ootdData['score'] as num?)?.toDouble() ?? 0.0;
    final grade = details['overallGrade'] as String? ?? 'C';
    final comment = details['overallComment'] as String? ?? '';

    // 등급별 색상
    final gradeColors = {
      'S': const Color(0xFFFFD700), // Gold
      'A': const Color(0xFF10B981), // Green
      'B': const Color(0xFF3B82F6), // Blue
      'C': const Color(0xFF6B7280), // Gray
    };

    final gradeColor = gradeColors[grade] ?? colors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        children: [
          // 점수 + 등급
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: context.heading1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
              Text(
                '/10',
                style: context.heading3.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border: Border.all(
                    color: gradeColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  grade,
                  style: context.heading2.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          // 전체 코멘트
          if (comment.isNotEmpty)
            Text(
              comment,
              style: context.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final highlights = (details['highlights'] as List<dynamic>?)?.cast<String>() ?? [];

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
              const Text('💫', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '칭찬 포인트',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          ...highlights.map((highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: context.bodyMedium.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        highlight,
                        style: context.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryScoresSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final categories = details['categories'] as Map<String, dynamic>? ?? {};

    if (categories.isEmpty) return const SizedBox.shrink();

    final categoryLabels = {
      'colorHarmony': ('🎨', '색상 조화'),
      'silhouette': ('👔', '실루엣'),
      'styleConsistency': ('✨', '스타일 일관성'),
      'accessories': ('💍', '액세서리'),
    };

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
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '세부 평가',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...categories.entries.map((entry) {
            final categoryInfo = categoryLabels[entry.key];
            if (categoryInfo == null) return const SizedBox.shrink();

            final data = entry.value as Map<String, dynamic>? ?? {};
            final score = (data['score'] as num?)?.toDouble() ?? 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: _buildScoreBar(
                context,
                emoji: categoryInfo.$1,
                label: categoryInfo.$2,
                score: score,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScoreBar(
    BuildContext context, {
    required String emoji,
    required String label,
    required double score,
  }) {
    final colors = context.colors;
    final normalizedScore = score / 10.0;

    // 점수별 색상
    Color barColor;
    if (score >= 8) {
      barColor = const Color(0xFF10B981);
    } else if (score >= 6) {
      barColor = const Color(0xFF3B82F6);
    } else if (score >= 4) {
      barColor = const Color(0xFFF59E0B);
    } else {
      barColor = const Color(0xFF6B7280);
    }

    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: colors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: normalizedScore.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.xs),
        SizedBox(
          width: 32,
          child: Text(
            score.toStringAsFixed(1),
            style: context.bodySmall.copyWith(
              color: barColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final suggestions =
        (details['softSuggestions'] as List<dynamic>?)?.cast<String>() ?? [];

    if (suggestions.isEmpty) return const SizedBox.shrink();

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
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '이렇게 하면 더 완벽해요!',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•', style: TextStyle(color: Color(0xFFF59E0B))),
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
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItemsSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final items = (details['recommendedItems'] as List<dynamic>?) ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

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
              const Text('🛒', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '추천 아이템',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          SizedBox(
            height: 100, // 80 → 100: 오버플로우 수정
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                return _buildRecommendedItemChip(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItemChip(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final colors = context.colors;
    final emoji = item['emoji'] as String? ?? '👕';
    final category = item['category'] as String? ?? '';
    final itemName = item['item'] as String? ?? '';
    final reason = item['reason'] as String? ?? '';

    return Container(
      width: 150, // 140 → 150: 더 넓게
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surface,
            colors.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 오버플로우 방지
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: DSSpacing.xs),
              Expanded(
                child: Text(
                  itemName,
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              reason,
              style: context.labelSmall.copyWith(
                color: colors.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrityMatchSection(BuildContext context) {
    final colors = context.colors;
    final details = ootdData['details'] as Map<String, dynamic>? ?? {};
    final celebMatch = details['celebrityMatch'] as Map<String, dynamic>?;

    if (celebMatch == null) return const SizedBox.shrink();

    final name = celebMatch['name'] as String? ?? '';
    final similarity = (celebMatch['similarity'] as num?)?.toInt() ?? 0;
    final reason = celebMatch['reason'] as String? ?? '';

    if (name.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      margin: const EdgeInsets.only(
        left: DSSpacing.md,
        right: DSSpacing.md,
        bottom: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFFEC4899).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '셀럽 스타일 매칭',
                      style: context.labelSmall.copyWith(
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                      ),
                      child: Text(
                        '$similarity%',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                if (reason.isNotEmpty)
                  Text(
                    reason,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
