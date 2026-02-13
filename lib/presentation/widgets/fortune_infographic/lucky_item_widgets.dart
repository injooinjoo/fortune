import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/design_system.dart';
import 'helpers.dart';

/// Lucky item display widgets for fortune infographic
class LuckyItemWidgets {
  LuckyItemWidgets._();

  /// Lucky items grid
  static Widget buildLuckyItemsGrid({
    required List<Map<String, dynamic>> items,
    int crossAxisCount = 2,
    double? itemSize,
    List<Map<String, dynamic>>? luckyItems,
  }) {
    // Handle alternate signature
    final actualItems = luckyItems ?? items;

    if (actualItems.isEmpty) {
      return const Center(
        child: Text(
          '행운 아이템이 없습니다',
          style: TextStyle(color: DSColors.textTertiaryDark),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actualItems.length,
          itemBuilder: (context, index) {
            final item = actualItems[index];
            final type = item['type'] ?? '';
            final title = item['title'] ?? '';
            final value = item['value'] ?? '';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? DSColors.surfaceSecondary
                    : DSColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FortuneInfographicHelpers.getLuckyItemColor(type).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FortuneInfographicHelpers.getLuckyItemIcon(type),
                    size: itemSize ?? 32,
                    color: FortuneInfographicHelpers.getLuckyItemColor(type),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: context.labelMedium.copyWith(
                      color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100));
          },
        );
      },
    );
  }

  /// Lucky tags with color, food, numbers, and direction
  static Widget buildTossStyleLuckyTags({
    String? luckyColor,
    String? luckyFood,
    List<String>? luckyNumbers,
    String? luckyDirection,
  }) {
    return Builder(
      builder: (context) {
        final isDark = context.isDark;

        final tags = <Map<String, dynamic>>[];

        if (luckyColor != null) {
          tags.add({'icon': Icons.palette, 'label': '색상', 'value': luckyColor, 'color': DSColors.accentSecondary});
        }
        if (luckyFood != null) {
          tags.add({'icon': Icons.restaurant, 'label': '음식', 'value': luckyFood, 'color': DSColors.warning});
        }
        if (luckyNumbers != null && luckyNumbers.isNotEmpty) {
          tags.add({'icon': Icons.numbers, 'label': '숫자', 'value': luckyNumbers.join(', '), 'color': DSColors.success});
        }
        if (luckyDirection != null) {
          tags.add({'icon': Icons.explore, 'label': '방향', 'value': luckyDirection, 'color': DSColors.info});
        }

        if (tags.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? DSColors.surfaceSecondary : DSColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? DSColors.border : DSColors.borderDark,
              ),
            ),
            child: Center(
              child: Text(
                '행운 아이템 준비 중...',
                style: TextStyle(
                  color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                ),
              ),
            ),
          );
        }

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
                  Text(
                    '행운 아이템',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (tag['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (tag['color'] as Color).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tag['icon'] as IconData,
                          size: 16,
                          color: tag['color'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag['label'] as String,
                              style: context.labelSmall.copyWith(
                                color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                              ),
                            ),
                            Text(
                              tag['value'] as String,
                              style: context.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: tag['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Lucky outfit (placeholder implementation)
  static Widget buildTossStyleLuckyOutfit({
    String? outfitDescription,
    List<String>? outfitItems,
    String? outfitStyle,
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
              Row(
                children: [
                  Icon(
                    Icons.checkroom,
                    size: 20,
                    color: isDark ? DSColors.accent : DSColors.accentDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 추천 스타일',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? DSColors.textPrimary : DSColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (outfitDescription != null)
                Text(
                  outfitDescription,
                  style: context.bodySmall.copyWith(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                    height: 1.4,
                  ),
                )
              else
                Text(
                  '스타일 추천 준비 중...',
                  style: TextStyle(
                    color: isDark ? DSColors.textTertiary : DSColors.textSecondaryDark,
                  ),
                ),
              if (outfitItems != null && outfitItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: outfitItems.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: DSColors.accentDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item,
                        style: context.labelMedium.copyWith(
                          color: DSColors.accentDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Saju lucky items (placeholder implementation)
  static Widget buildSajuLuckyItems(
    Map<String, dynamic>? sajuInsight, {
    required bool isDarkMode,
  }) {
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
          '사주 행운 아이템 준비 중...',
          style: TextStyle(
            color: isDarkMode ? DSColors.textTertiary : DSColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
