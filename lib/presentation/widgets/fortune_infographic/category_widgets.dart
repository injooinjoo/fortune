import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'helpers.dart';

/// Category display widgets for fortune infographic
class CategoryWidgets {
  CategoryWidgets._();

  /// Category cards implementation
  static Widget buildCategoryCards(
    Map<String, dynamic> categories, {
    required bool isDarkMode,
  }) {
    // total 카테고리 추출
    final totalData = categories['total'] as Map<String, dynamic>?;

    // 나머지 카테고리 데이터 정리 (5개: love, money, work, study, health)
    final categoryEntries = categories.entries.where((entry) =>
      entry.value is Map &&
      entry.value['score'] != null &&
      entry.key != 'total' // total은 별도로 표시
    ).toList();

    if (categoryEntries.isEmpty && totalData == null) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? DSColors.surfaceSecondary : DSColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? DSColors.border : DSColors.borderDark,
          ),
        ),
        child: Center(
          child: Text(
            '카테고리 데이터를 불러오는 중...',
            style: TextStyle(
              color: isDarkMode ? DSColors.textTertiary : DSColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // 총운 카드 (4자성어 표시)
        if (totalData != null) ...[
          _buildTotalFortuneCard(
            totalData: totalData,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
        ],

        // 나머지 카테고리 세로 나열 (5개) - 각 카드가 전체 너비 사용
        Column(
          children: categoryEntries.map((entry) {
            final categoryKey = entry.key;
            final categoryData = entry.value as Map<String, dynamic>;
            final score = categoryData['score'] as int? ?? 0;
            final title = categoryData['title'] as String? ?? FortuneInfographicHelpers.getDefaultCategoryTitle(categoryKey);

            // advice 필드 사용 (300자 텍스트), 없으면 short 또는 fallback
            String description;
            final advice = categoryData['advice'];
            if (advice is String && advice.isNotEmpty) {
              description = advice;  // 300자 조언
            } else {
              description = categoryData['short'] as String? ?? FortuneInfographicHelpers.getDefaultCategoryShort(categoryKey, score);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(
                title: title,
                score: score,
                description: description,
                isDarkMode: isDarkMode,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 총운 카드 (4자성어 표시)
  static Widget _buildTotalFortuneCard({
    required Map<String, dynamic> totalData,
    required bool isDarkMode,
  }) {
    final score = totalData['score'] as int? ?? 0;
    final scoreColor = FortuneInfographicHelpers.getCategoryScoreColor(score, isDarkMode);

    // advice가 객체인 경우와 문자열인 경우 모두 처리
    String idiom = '만사형통';
    String description = '균형잡힌 하루를 보내세요';

    final advice = totalData['advice'];
    if (advice is Map<String, dynamic>) {
      idiom = advice['idiom'] as String? ?? '만사형통';
      description = advice['description'] as String? ?? '균형잡힌 하루를 보내세요';
    } else if (advice is String) {
      description = advice;
    }

    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
              ? [
                  DSColors.surfaceSecondary,
                  DSColors.border.withValues(alpha: 0.5),
                ]
              : [
                  DSColors.surfaceDark,
                  scoreColor.withValues(alpha: 0.05),
                ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scoreColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 제목과 점수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '오늘의 총운',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? DSColors.textPrimary : DSColors.textPrimaryDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$score점',
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4자성어 (가장 눈에 띄게)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  idiom,
                  style: context.displaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 설명 텍스트
            Text(
              description,
              style: context.bodySmall.copyWith(
                color: isDarkMode ? DSColors.toggleInactive : DSColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategoryCard({
    required String title,
    required int score,
    required String description,
    required bool isDarkMode,
  }) {
    final scoreColor = FortuneInfographicHelpers.getCategoryScoreColor(score, isDarkMode);

    return Builder(
      builder: (context) => Container(
        width: double.infinity,  // 전체 너비 사용
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? DSColors.surfaceSecondary : DSColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? DSColors.border : DSColors.borderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score점',
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 높이 제한 없이 자연스럽게 표시 (300자 설명 모두 보임)
            Text(
              description,
              style: context.bodySmall.copyWith(
                color: isDarkMode ? DSColors.toggleInactive : DSColors.textSecondaryDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fortune summary with user profile information
  static Widget buildTossStyleFortuneSummary({
    Map<String, dynamic>? fortuneSummary,
    String? userZodiacAnimal,
    String? userZodiacSign,
    String? userMBTI,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        // Extract summary from fortuneSummary data
        final summary = fortuneSummary?['summary'] as String? ??
                       fortuneSummary?['description'] as String? ??
                       FortuneInfographicHelpers.getDefaultFortuneSummary(userZodiacAnimal, userZodiacSign, userMBTI);

        final title = fortuneSummary?['title'] as String? ?? '오늘의 운세 요약';
        final score = fortuneSummary?['score'] as int? ?? 75;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: isDark ? DSColors.accent : DSColors.accentDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FortuneInfographicHelpers.getCategoryScoreColor(score, isDark).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$score점',
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: FortuneInfographicHelpers.getCategoryScoreColor(score, isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: context.bodySmall.copyWith(
                  height: 1.4,
                  color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                ),
              ),
              if (userZodiacAnimal != null || userZodiacSign != null || userMBTI != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (userZodiacAnimal != null) ...[
                      _buildProfileTag(context, userZodiacAnimal, isDark),
                      const SizedBox(width: 8),
                    ],
                    if (userZodiacSign != null) ...[
                      _buildProfileTag(context, userZodiacSign, isDark),
                      const SizedBox(width: 8),
                    ],
                    if (userMBTI != null) ...[
                      _buildProfileTag(context, userMBTI, isDark),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _buildProfileTag(BuildContext context, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
          ? DSColors.accent.withValues(alpha: 0.2)
          : DSColors.accentDark.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: context.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? DSColors.accent : DSColors.accentDark,
        ),
      ),
    );
  }

  /// AI insights card with real data display
  static Widget buildAIInsightsCard({
    String? insight,
    List<String>? tips,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AI icon
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DSFortuneColors.categoryPersonalityDna, DSFortuneColors.categoryMbti],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '신의 통찰',
                    style: TextStyle(
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main insight text
              if (insight != null && insight.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DSColors.border.withValues(alpha: 0.5)
                        : DSColors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    insight,
                    style: TextStyle(
                      color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tips section
              if (tips != null && tips.isNotEmpty) ...[
                Text(
                  '✨ 추천 팁',
                  style: TextStyle(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.take(3).map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: const BoxDecoration(
                          color: DSFortuneColors.categoryPersonalityDna,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],

              // Fallback when no data
              if ((insight == null || insight.isEmpty) && (tips == null || tips.isEmpty))
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '신의 통찰 준비 중...',
                      style: TextStyle(
                        color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
