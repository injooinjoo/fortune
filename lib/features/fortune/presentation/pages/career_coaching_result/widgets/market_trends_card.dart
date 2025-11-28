import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';

class MarketTrendsCard extends StatelessWidget {
  final Map<String, dynamic> marketTrends;
  final bool isDark;

  const MarketTrendsCard({
    super.key,
    required this.marketTrends,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final industryOutlook = marketTrends['industry_outlook'] as String? ?? '';
    final demandLevel = marketTrends['demand_level'] as String? ?? '';
    final salaryTrend = marketTrends['salary_trend'] as String? ?? '';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: TossDesignSystem.tossBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '시장 트렌드',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTrendItem(context, '업계 전망', _getTrendLabel(industryOutlook), _getTrendColor(industryOutlook), isDark),
          _buildTrendItem(context, '수요 수준', _getDemandLabel(demandLevel), _getDemandColor(demandLevel), isDark),
          _buildTrendItem(context, '연봉 추세', salaryTrend, TossDesignSystem.gray800, isDark),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildTrendItem(BuildContext context, String label, String value, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.gray600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: context.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendLabel(String outlook) {
    switch (outlook) {
      case 'positive': return '긍정적';
      case 'stable': return '안정적';
      case 'challenging': return '도전적';
      default: return outlook;
    }
  }

  Color _getTrendColor(String outlook) {
    switch (outlook) {
      case 'positive': return TossDesignSystem.successGreen;
      case 'stable': return TossDesignSystem.tossBlue;
      case 'challenging': return TossDesignSystem.warningOrange;
      default: return TossDesignSystem.gray600;
    }
  }

  String _getDemandLabel(String level) {
    switch (level) {
      case 'high': return '높음';
      case 'moderate': return '보통';
      case 'low': return '낮음';
      default: return level;
    }
  }

  Color _getDemandColor(String level) {
    switch (level) {
      case 'high': return TossDesignSystem.successGreen;
      case 'moderate': return TossDesignSystem.tossBlue;
      case 'low': return TossDesignSystem.warningOrange;
      default: return TossDesignSystem.gray600;
    }
  }
}
