import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/widgets/gpt_style_typing_text.dart';

class InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final int index;
  final DSColorScheme colors;
  final bool enableTyping;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const InsightCard({
    super.key,
    required this.insight,
    required this.index,
    required this.colors,
    this.enableTyping = false,
    this.startTyping = true,
    this.onTypingComplete,
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
                  child: Text(icon, style: DSTypography.headingLarge),
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
                            style: DSTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
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
                            style: DSTypography.labelSmall.copyWith(
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
                      style: DSTypography.labelMedium.copyWith(
                        color: _getInsightColor(category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          enableTyping
              ? GptStyleTypingText(
                  text: description,
                  style: DSTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                  showGhostText: true,
                  startTyping: startTyping,
                  onComplete: onTypingComplete,
                )
              : Text(
                  description,
                  style: DSTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: colors.textSecondary,
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
      case 'opportunity': return DSColors.success;
      case 'warning': return DSColors.warning;
      case 'trend': return colors.accent;
      case 'advice': return colors.accent;
      default: return colors.textSecondary;
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
      case 'high': return DSColors.error;
      case 'medium': return DSColors.warning;
      case 'low': return colors.textSecondary;
      default: return colors.textSecondary;
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
