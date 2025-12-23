import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/features/fortune/domain/models/mbti_dimension_fortune.dart';

/// 개별 차원 운세 카드
///
/// 점수만 무료로 공개되고, fortune/tip은 블러 처리됩니다.
class DimensionFortuneCard extends StatelessWidget {
  final MbtiDimensionFortune dimension;
  final bool isBlurred;

  const DimensionFortuneCard({
    super.key,
    required this.dimension,
    this.isBlurred = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? dimension.color.withValues(alpha: 0.15)
            : dimension.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dimension.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 타이틀 + 차원
          Row(
            children: [
              Text(
                dimension.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dimension.title,
                      style: TextStyle(
                        fontSize: FontConfig.labelMedium,
                        fontWeight: FontWeight.w600,
                        color: themeColors.textPrimary,
                      ),
                    ),
                    Text(
                      dimension.dimension,
                      style: TextStyle(
                        fontSize: FontConfig.labelSmall,
                        fontWeight: FontWeight.w700,
                        color: dimension.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 점수 (무료 공개)
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: dimension.gradient,
                ).createShader(bounds),
                child: Text(
                  '${dimension.score}',
                  style: const TextStyle(
                    fontSize: FontConfig.displayMedium,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '점',
                style: TextStyle(
                  fontSize: FontConfig.labelMedium,
                  fontWeight: FontWeight.w600,
                  color: dimension.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 점수 바
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: themeColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: dimension.score / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: dimension.gradient),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 운세 텍스트 (블러 처리)
          _buildBlurrableText(
            text: dimension.fortune,
            style: TextStyle(
              fontSize: FontConfig.bodySmall,
              color: themeColors.textSecondary,
              height: 1.4,
            ),
            isBlurred: isBlurred,
          ),
          const SizedBox(height: 8),

          // 팁 (블러 처리)
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 14,
                color: dimension.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildBlurrableText(
                  text: dimension.tip,
                  style: TextStyle(
                    fontSize: FontConfig.labelSmall,
                    color: dimension.color,
                    fontWeight: FontWeight.w500,
                  ),
                  isBlurred: isBlurred,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurrableText({
    required String text,
    required TextStyle style,
    required bool isBlurred,
  }) {
    if (!isBlurred) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    // 블러 효과: 회색 박스로 대체
    return Container(
      height: (style.fontSize ?? 14) * 1.4 * 2, // 2줄 높이
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 12,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '광고 시청 후 공개',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4차원 그리드 카드 (2x2 레이아웃)
class DimensionsGridCard extends StatelessWidget {
  final List<MbtiDimensionFortune> dimensions;
  final bool isBlurred;

  const DimensionsGridCard({
    super.key,
    required this.dimensions,
    this.isBlurred = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dimensions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 첫 번째 줄 (E/I, N/S)
        Row(
          children: [
            if (dimensions.isNotEmpty)
              Expanded(
                child: DimensionFortuneCard(
                  dimension: dimensions[0],
                  isBlurred: isBlurred,
                ),
              ),
            const SizedBox(width: 12),
            if (dimensions.length > 1)
              Expanded(
                child: DimensionFortuneCard(
                  dimension: dimensions[1],
                  isBlurred: isBlurred,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // 두 번째 줄 (T/F, J/P)
        Row(
          children: [
            if (dimensions.length > 2)
              Expanded(
                child: DimensionFortuneCard(
                  dimension: dimensions[2],
                  isBlurred: isBlurred,
                ),
              ),
            const SizedBox(width: 12),
            if (dimensions.length > 3)
              Expanded(
                child: DimensionFortuneCard(
                  dimension: dimensions[3],
                  isBlurred: isBlurred,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
