import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/components/app_card.dart';

class InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final int index;
  final bool isDark;

  const InsightCard({
    super.key,
    required this.insight,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final icon = insight['icon'] as String? ?? '💡';
    final title = insight['title'] as String? ?? '';
    final category = insight['category'] as String? ?? '';
    final impact = insight['impact'] as String? ?? '';
    final description = insight['description'] as String? ?? '';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getInsightColor(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: context.displaySmall),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: context.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getImpactColor(impact).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getImpactLabel(impact),
                            style: context.labelSmall.copyWith(
                              color: _getImpactColor(impact),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryLabel(category),
                      style: context.labelMedium.copyWith(
                        color: _getInsightColor(category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: context.bodyMedium.copyWith(
              height: 1.6,
              color: TossDesignSystem.gray700,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn(duration: 500.ms)
      .slideX(begin: 0.1);
  }

  Color _getInsightColor(String category) {
    switch (category) {
      case 'opportunity': return TossDesignSystem.successGreen;
      case 'warning': return TossDesignSystem.warningOrange;
      case 'trend': return TossDesignSystem.tossBlue;
      case 'advice': return AppTheme.primaryColor;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'opportunity': return '기회';
      case 'warning': return '주의';
      case 'trend': return '트렌드';
      case 'advice': return '조언';
      default: return category;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'high': return TossDesignSystem.errorRed;
      case 'medium': return TossDesignSystem.warningOrange;
      case 'low': return TossDesignSystem.gray600;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getImpactLabel(String impact) {
    switch (impact) {
      case 'high': return '높음';
      case 'medium': return '중간';
      case 'low': return '낮음';
      default: return impact;
    }
  }
}
