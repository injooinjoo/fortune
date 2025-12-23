import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 스타일링 추천 위젯
class BlindDateOutfitRecommendation extends StatelessWidget {
  final String? meetingType;

  const BlindDateOutfitRecommendation({
    super.key,
    this.meetingType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outfitStyle = _getOutfitStyle();
    final luckyColors = _getLuckyColors();

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.checkroom,
                color: colors.accent,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '스타일링 추천',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              )
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 추천 스타일
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent.withValues(alpha: 0.05),
                  colors.accentSecondary.withValues(alpha: 0.05)
                ],
              ),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 스타일',
                  style: DSTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  outfitStyle,
                  style: DSTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          // 행운의 색상
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 20,
                color: colors.accent,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '행운의 색상',
                style: DSTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Row(
            children: luckyColors
                .map((colorData) => Padding(
                      padding: const EdgeInsets.only(right: DSSpacing.sm),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorData['color'] as Color,
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                          border: Border.all(
                            color: colors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            colorData['name'] as String,
                            style: DSTypography.labelSmall.copyWith(
                              color: (colorData['color'] as Color).computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _getOutfitStyle() {
    switch (meetingType) {
      case 'coffee':
        return '캐주얼하면서도 깔끔한 스타일. 편안한 니트나 셔츠에 청바지나 슬랙스를 매치하세요.';
      case 'meal':
        return '세미 포멀한 스타일. 블라우스나 셔츠에 깔끔한 하의를 매치하세요.';
      case 'activity':
        return '활동적이면서도 스타일리시한 룩. 운동화와 함께 편안한 옷차림을 선택하세요.';
      case 'walk':
        return '편안하고 자연스러운 스타일. 걷기 편한 신발은 필수입니다.';
      default:
        return '깔끔하고 단정한 스타일. 자신감 있게 입을 수 있는 옷을 선택하세요.';
    }
  }

  List<Map<String, dynamic>> _getLuckyColors() {
    return [
      {'name': '블루', 'color': const Color(0xFF3182F6)},
      {'name': '화이트', 'color': Colors.white},
      {'name': '핑크', 'color': const Color(0xFFEC4899)},
    ];
  }
}
