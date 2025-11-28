import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final locationAdvice = _getLocationAdvice();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '장소 & 분위기',
                    style: theme.textTheme.headlineSmall,
                  )
                ],
              ),
              const SizedBox(height: 16),
              ...locationAdvice.map((advice) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            advice,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '조용하고 대화하기 좋은 장소를 선택하세요. 너무 시끄럽거나 붐비는 곳은 피하는 것이 좋습니다.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
