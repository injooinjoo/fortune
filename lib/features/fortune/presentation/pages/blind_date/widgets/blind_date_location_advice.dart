import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

/// 장소 & 분위기 조언 위젯
class BlindDateLocationAdvice extends StatelessWidget {
  final String? meetingType;

  const BlindDateLocationAdvice({
    super.key,
    this.meetingType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locationAdvice = _getLocationAdvice();

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: colors.accentSecondary,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '장소 & 분위기',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              )
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 조언 리스트
          ...locationAdvice.map((advice) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Text(
                        advice,
                        style: DSTypography.bodyMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: DSSpacing.sm),
          // 팁 박스
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  size: 20,
                  color: colors.accent,
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    '조용하고 대화하기 좋은 장소를 선택하세요. 너무 시끄럽거나 붐비는 곳은 피하는 것이 좋습니다.',
                    style: DSTypography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getLocationAdvice() {
    switch (meetingType) {
      case 'coffee':
        return [
          '분위기 좋은 독립 카페 추천, 창가 자리나 조용한 코너 선택',
          '음악이 너무 크지 않은 곳'
        ];
      case 'meal':
        return [
          '예약 가능한 레스토랑 선택, 메뉴가 다양한 곳 추천',
          '개인 공간이 보장되는 자리'
        ];
      case 'activity':
        return [
          '서로 즐길 수 있는 활동 선택, 대화할 기회가 있는 활동',
          '너무 경쟁적이지 않은 분위기'
        ];
      default:
        return [
          '편안한 분위기의 장소, 대화에 집중할 수 있는 환경',
          '적당한 프라이버시 보장'
        ];
    }
  }
}
