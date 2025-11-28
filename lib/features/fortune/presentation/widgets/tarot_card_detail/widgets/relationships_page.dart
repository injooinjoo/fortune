import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/constants/tarot_metadata.dart';

class RelationshipsPage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final int cardIndex;

  const RelationshipsPage({
    super.key,
    required this.cardInfo,
    required this.cardIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tarotCardInfo =
        cardIndex < 22 ? TarotMetadata.majorArcana[cardIndex] : null;

    if (tarotCardInfo?.cardCombinations == null) {
      return _buildComingSoonPage(context, '카드 조합', '곧 업데이트됩니다');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다른 카드와의 조합',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TossDesignSystem.spacingL),

          ...tarotCardInfo!.cardCombinations!.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingM),
              child: GlassContainer(
                padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.purple.withValues(alpha: 0.1),
                    TossDesignSystem.purple.withValues(alpha: 0.1)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: TossDesignSystem.purple,
                          size: 24,
                        ),
                        const SizedBox(width: TossDesignSystem.spacingS),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TossDesignSystem.spacingS),
                    Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (tarotCardInfo.colorSymbolism != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '색채 상징',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                  TossDesignSystem.warningOrange.withValues(alpha: 0.1)
                ],
              ),
              child: Text(
                tarotCardInfo.colorSymbolism!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],

          if (tarotCardInfo.crystals != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '연관 크리스탈',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...tarotCardInfo.crystals!.map(
              (crystal) => Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                child: GlassContainer(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
                      TossDesignSystem.primaryBlue.withValues(alpha: 0.1)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: TossDesignSystem.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          crystal,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComingSoonPage(
      BuildContext context, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: TossDesignSystem.purple,
          ),
          const SizedBox(height: TossDesignSystem.spacingXL),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: TossDesignSystem.spacingM),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
