import 'package:flutter/material.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

/// 운세 섹션 카드 빌더
class FortuneSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;
  final bool isWarning;

  const FortuneSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    // 문단 구분을 위해 '. '으로 문장 분리
    final sentences = content.split('. ').where((s) => s.trim().isNotEmpty).toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning
                  ? TossDesignSystem.errorRed
                  : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.heading4.copyWith(
                  color: isWarning
                    ? TossDesignSystem.errorRed
                    : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 문장별로 구분하여 표시
          ...sentences.asMap().entries.map((entry) {
            final index = entry.key;
            final sentence = entry.value.trim();
            final isLastSentence = index == sentences.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLastSentence ? 0 : 16),
              child: Text(
                sentence + (sentence.endsWith('.') ? '' : '.'),
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  height: 1.8,
                  letterSpacing: -0.3,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 카테고리별 운세 섹션
class CategoriesSection extends StatelessWidget {
  final Map<String, dynamic> categories;
  final bool isDark;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.isDark,
  });

  static const List<Map<String, dynamic>> categoryData = [
    {'key': 'love', 'title': '애정 운세', 'icon': Icons.favorite_outline, 'color': Colors.pink},
    {'key': 'work', 'title': '직장 운세', 'icon': Icons.work_outline, 'color': Colors.blue},
    {'key': 'money', 'title': '금전 운세', 'icon': Icons.attach_money, 'color': Colors.green},
    {'key': 'study', 'title': '학업 운세', 'icon': Icons.school_outlined, 'color': Colors.orange},
    {'key': 'health', 'title': '건강 운세', 'icon': Icons.favorite_border, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '카테고리별 운세',
            style: context.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
        ),
        ...categoryData.map((cat) {
          final categoryInfo = categories[cat['key']];
          if (categoryInfo == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['title'] as String,
                        style: context.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categoryInfo['score']}점',
                          style: context.labelMedium.copyWith(
                            color: cat['color'] as Color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (categoryInfo['title'] != null)
                    Text(
                      FortuneTextCleaner.clean(categoryInfo['title'] as String),
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (categoryInfo['advice'] != null)
                    Text(
                      FortuneTextCleaner.cleanAndTruncate(categoryInfo['advice'] as String),
                      style: context.bodySmall.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        // 전체 운세
        if (categories['total'] != null) ...[
          const SizedBox(height: 4),
          _buildTotalFortuneCard(context),
        ],
      ],
    );
  }

  Widget _buildTotalFortuneCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        style: AppCardStyle.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '전체 운세',
                  style: context.heading4.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${categories['total']['score']}점',
                    style: context.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (categories['total']['advice'] is Map) ...[
              // advice가 Map 구조인 경우 (idiom + description)
              Text(
                FortuneTextCleaner.clean((categories['total']['advice'] as Map)['idiom'] as String? ?? ''),
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                FortuneTextCleaner.cleanAndTruncate((categories['total']['advice'] as Map)['description'] as String? ?? ''),
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  height: 1.6,
                ),
              ),
            ] else ...[
              // advice가 String인 경우 (하위 호환)
              Text(
                FortuneTextCleaner.cleanAndTruncate(categories['total']['advice'] as String? ?? ''),
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AI 팁 리스트 위젯
class AITipsList extends StatelessWidget {
  final List tips;
  final bool isDark;

  const AITipsList({
    super.key,
    required this.tips,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 팁',
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.labelSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      FortuneTextCleaner.cleanAndTruncate(tip, maxLength: 80),
                      style: context.bodyMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        height: 1.5,
                      ),
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
}
