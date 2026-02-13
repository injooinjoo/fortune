import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/design_system/design_system.dart';
import '../../../../fortune/data/models/investment_ticker.dart';

/// 채팅 설문용 투자 카테고리 선택 위젯
class ChatInvestmentCategorySelector extends StatelessWidget {
  final ValueChanged<InvestmentCategory> onCategorySelected;

  const ChatInvestmentCategorySelector({
    super.key,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 그리드
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: DSSpacing.sm,
            crossAxisSpacing: DSSpacing.sm,
            childAspectRatio: 1.6,
            children: InvestmentCategory.values.map((category) {
              return _CategoryCard(
                category: category,
                colors: colors,
                typography: typography,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategorySelected(category);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final InvestmentCategory category;
  final DSColorScheme colors;
  final DSTypographyScheme typography;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  String get _emoji {
    switch (category) {
      case InvestmentCategory.crypto:
        return '₿';
      case InvestmentCategory.krStock:
        return '🇰🇷';
      case InvestmentCategory.usStock:
        return '🇺🇸';
      case InvestmentCategory.etf:
        return '📊';
      case InvestmentCategory.commodity:
        return '🪙';
      case InvestmentCategory.realEstate:
        return '🏠';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: DSSpacing.xs),
              Text(
                category.label,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                category.description,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
