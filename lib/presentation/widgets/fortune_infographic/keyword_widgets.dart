import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_design_system.dart';
import 'helpers.dart';

/// Keyword display widgets for fortune infographic
class KeywordWidgets {
  KeywordWidgets._();

  /// Keyword cloud widget
  static Widget buildKeywordCloud({
    required List<String> keywords,
    double maxFontSize = 32,
    double minFontSize = 14,
    Map<String, double>? importance,
  }) {
    if (keywords.isEmpty) {
      return Center(
        child: Text(
          '키워드가 없습니다',
          style: TextStyle(color: TossDesignSystem.gray500),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            final weight = importance?[keyword] ?? 0.5;
            final fontSize = minFontSize + (maxFontSize - minFontSize) * weight;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FortuneInfographicHelpers.getKeywordColor(weight).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FortuneInfographicHelpers.getKeywordColor(weight).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                keyword,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.white : FortuneInfographicHelpers.getKeywordColor(weight),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 토스 스타일 키워드 섹션 (개선된 디자인)
  static Widget buildTossStyleKeywordSection({
    required List<String> keywords,
    required Map<String, double> importance,
    required BuildContext context,
  }) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
              ]
            : [
                TossDesignSystem.white,
                const Color(0xFFF8FAFC),
              ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
            ? TossDesignSystem.purple.withValues(alpha: 0.2)
            : TossDesignSystem.tossBlue.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
              ? TossDesignSystem.purple.withValues(alpha: 0.1)
              : TossDesignSystem.tossBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                      ? [TossDesignSystem.purple, TossDesignSystem.purple.withValues(alpha: 0.8)]
                      : [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: TossDesignSystem.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 키워드',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '당신을 위한 특별한 메시지',
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 키워드 클라우드
          _buildEnhancedKeywordCloud(keywords, importance, isDark),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  /// 향상된 키워드 클라우드
  static Widget _buildEnhancedKeywordCloud(
    List<String> keywords,
    Map<String, double> importance,
    bool isDark
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: keywords.asMap().entries.map((entry) {
        final index = entry.key;
        final keyword = entry.value;
        final weight = importance[keyword] ?? 0.5;
        final isHighPriority = weight > 0.7;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHighPriority ? 16 : 12,
            vertical: isHighPriority ? 10 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHighPriority
                ? isDark
                  ? [
                      TossDesignSystem.purple.withValues(alpha: 0.2),
                      TossDesignSystem.purple.withValues(alpha: 0.1),
                    ]
                  : [
                      TossDesignSystem.tossBlue.withValues(alpha: 0.15),
                      TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                    ]
                : isDark
                  ? [
                      TossDesignSystem.grayDark400.withValues(alpha: 0.3),
                      TossDesignSystem.grayDark400.withValues(alpha: 0.1),
                    ]
                  : [
                      TossDesignSystem.gray100,
                      TossDesignSystem.gray50,
                    ],
            ),
            borderRadius: BorderRadius.circular(isHighPriority ? 16 : 12),
            border: Border.all(
              color: isHighPriority
                ? isDark
                  ? TossDesignSystem.purple.withValues(alpha: 0.4)
                  : TossDesignSystem.tossBlue.withValues(alpha: 0.3)
                : isDark
                  ? TossDesignSystem.grayDark500.withValues(alpha: 0.5)
                  : TossDesignSystem.gray200,
              width: isHighPriority ? 1.5 : 1,
            ),
            boxShadow: isHighPriority ? [
              BoxShadow(
                color: (isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHighPriority) ...[
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: isDark ? TossDesignSystem.purple : TossDesignSystem.tossBlue,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                keyword,
                style: TextStyle(
                  fontSize: isHighPriority ? 16 : 14,
                  fontWeight: isHighPriority ? FontWeight.bold : FontWeight.w600,
                  color: isHighPriority
                    ? isDark
                      ? TossDesignSystem.purple
                      : TossDesignSystem.tossBlue
                    : isDark
                      ? TossDesignSystem.white
                      : TossDesignSystem.gray800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 * index))
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
          .fadeIn();
      }).toList(),
    );
  }
}
