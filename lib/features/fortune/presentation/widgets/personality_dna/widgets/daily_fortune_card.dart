import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 데일리 운세 카드
class DailyFortuneCard extends StatelessWidget {
  final DailyFortune dailyFortune;

  // 테마 색상 상수
  static const Color _primaryColor = Color(0xFF9B59B6);
  static const Color _successColor = Color(0xFF2ECC71);
  static const Color _warningColor = Color(0xFFE74C3C);

  const DailyFortuneCard({super.key, required this.dailyFortune});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryColor.withValues(alpha: isDark ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '오늘의 데일리',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 럭키 아이템 그리드
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  context,
                  isDark,
                  '🎨',
                  '럭키 컬러',
                  dailyFortune.luckyColor,
                  const Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildLuckyItem(
                  context,
                  isDark,
                  '🔢',
                  '럭키 넘버',
                  dailyFortune.luckyNumber.toString(),
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildLuckyItem(
                  context,
                  isDark,
                  '⚡',
                  '에너지',
                  '${dailyFortune.energyLevel}%',
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 추천 활동
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: _successColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _successColor.withValues(alpha: isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 활동',
                        style: context.labelLarge.copyWith(
                          color: _successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        dailyFortune.recommendedActivity,
                        style: context.bodyMedium.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 주의사항
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: _warningColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _warningColor.withValues(alpha: isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주의사항',
                        style: context.labelLarge.copyWith(
                          color: _warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        dailyFortune.caution,
                        style: context.bodyMedium.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          // 오늘의 최고 궁합
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('💫', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 최고 궁합',
                        style: context.labelLarge.copyWith(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        dailyFortune.bestMatchToday,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(
    BuildContext context,
    bool isDark,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.75 : 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
