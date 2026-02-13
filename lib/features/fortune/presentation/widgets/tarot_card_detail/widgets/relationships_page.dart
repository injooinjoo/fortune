import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다른 카드와의 조합',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ...tarotCardInfo!.cardCombinations!.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                gradient: LinearGradient(
                  colors: [
                    DSColors.accentSecondary.withValues(alpha: 0.1),
                    DSColors.accentSecondary.withValues(alpha: 0.1)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: DSColors.accentSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
            const SizedBox(height: 32),
            Text(
              '색채 상징',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  DSColors.warning.withValues(alpha: 0.1),
                  DSColors.warning.withValues(alpha: 0.1)
                ],
              ),
              child: Text(
                tarotCardInfo.colorSymbolism!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          if (tarotCardInfo.crystals != null) ...[
            const SizedBox(height: 32),
            Text(
              '연관 크리스탈',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...tarotCardInfo.crystals!.map(
              (crystal) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(8),
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accent.withValues(alpha: 0.1),
                      DSColors.accent.withValues(alpha: 0.1)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.diamond,
                        color: DSColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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
            color: DSColors.accentSecondary,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
