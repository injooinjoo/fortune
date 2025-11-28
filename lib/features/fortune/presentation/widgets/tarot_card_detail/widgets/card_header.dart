import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

class TarotCardHeader extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final String? position;
  final int currentPage;

  const TarotCardHeader({
    super.key,
    required this.cardInfo,
    this.position,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final pageNames = [
      '카드 이미지',
      '스토리',
      '상징',
      '의미',
      '심화 해석',
      '실천 가이드',
      '관계성',
      '조언'
    ];

    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      child: Column(
        children: [
          Text(
            cardInfo['name'] ?? 'Unknown Card',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (position != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TossDesignSystem.spacingM,
                vertical: TossDesignSystem.spacingXXS * 1.5,
              ),
              decoration: BoxDecoration(
                color: TossDesignSystem.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                position!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
          const SizedBox(height: TossDesignSystem.spacingXS),
          Text(
            pageNames[currentPage],
            style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      ),
    );
  }
}
