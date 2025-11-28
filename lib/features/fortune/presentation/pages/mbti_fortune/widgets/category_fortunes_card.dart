import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/utils/fortune_text_cleaner.dart';

class CategoryFortunesCard extends StatelessWidget {
  final FortuneResult fortuneResult;
  final List<String> selectedCategories;

  static const List<Map<String, dynamic>> categories = [
    {'label': '연애운', 'icon': Icons.favorite, 'color': Color(0xFFEC4899)},
    {'label': '직업운', 'icon': Icons.work, 'color': Color(0xFF3B82F6)},
    {'label': '재물운', 'icon': Icons.attach_money, 'color': Color(0xFF10B981)},
    {'label': '건강운', 'icon': Icons.health_and_safety, 'color': Color(0xFFF59E0B)},
    {'label': '대인관계', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'label': '학업운', 'icon': Icons.school, 'color': Color(0xFF06B6D4)},
  ];

  const CategoryFortunesCard({
    super.key,
    required this.fortuneResult,
    required this.selectedCategories,
  });

  String _getCategoryFortune(String category) {
    const fortunes = {
      '연애운': '오늘은 사랑하는 사람과의 관계가 더욱 깊어질 수 있는 날입니다. 진심을 담은 대화를 나눠보세요.',
      '직업운': '새로운 프로젝트나 기회가 찾아올 수 있습니다. 적극적으로 도전해보세요.',
      '재물운': '예상치 못한 수입이 있을 수 있습니다. 하지만 충동적인 소비는 피하세요.',
      '건강운': '컨디션이 좋은 날입니다. 운동이나 야외 활동을 즐겨보세요.',
      '대인관계': '주변 사람들과의 관계가 원만해집니다. 새로운 인연도 기대해보세요.',
      '학업운': '집중력이 높아지는 날입니다. 어려운 문제도 해결할 수 있을 것입니다.',
    };
    return fortunes[category] ?? '오늘은 $category이 좋은 날입니다.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = fortuneResult.data as Map<String, dynamic>? ?? {};

    return Column(
      children: selectedCategories.map((category) {
        final categoryInfo = categories.firstWhere(
          (c) => c['label'] == category,
        );

        String categoryText = '';
        switch (category) {
          case '연애운':
            categoryText = FortuneTextCleaner.clean(data['loveFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '직업운':
            categoryText = FortuneTextCleaner.clean(data['careerFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '재물운':
            categoryText = FortuneTextCleaner.clean(data['moneyFortune'] as String? ?? _getCategoryFortune(category));
            break;
          case '건강운':
            categoryText = FortuneTextCleaner.clean(data['healthFortune'] as String? ?? _getCategoryFortune(category));
            break;
          default:
            categoryText = FortuneTextCleaner.clean(_getCategoryFortune(category));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      categoryInfo['icon'] as IconData,
                      size: 20,
                      color: categoryInfo['color'] as Color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  categoryText,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
