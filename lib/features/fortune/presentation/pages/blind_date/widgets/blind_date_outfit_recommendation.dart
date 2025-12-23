import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final outfitStyle = _getOutfitStyle();
    final colors = _getLuckyColors();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checkroom,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '스타일링 추천',
                    style: theme.textTheme.headlineSmall,
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                      theme.colorScheme.secondary.withValues(alpha: 0.05)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추천 스타일',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outfitStyle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.palette,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '행운의 색상',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: colors
                    .map((color) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color['color'],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                color['name'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      (color['color'] as Color).computeLuminance() >
                                              0.5
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
        ),
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
