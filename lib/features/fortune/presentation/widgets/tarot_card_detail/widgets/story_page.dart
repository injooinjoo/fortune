import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/constants/tarot_metadata.dart';

class StoryPage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final int cardIndex;

  const StoryPage({
    super.key,
    required this.cardInfo,
    required this.cardIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tarotCardInfo =
        cardIndex < 22 ? TarotMetadata.majorArcana[cardIndex] : null;

    if (tarotCardInfo?.story == null) {
      return _buildComingSoonPage(context, '스토리', '곧 업데이트됩니다');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 이야기',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),

          GlassContainer(
            padding: const EdgeInsets.all(24),
            gradient: LinearGradient(
              colors: [
                DSColors.accentSecondary.withValues(alpha: 0.1),
                DSColors.accent.withValues(alpha: 0.1)
              ],
            ),
            child: Text(
              tarotCardInfo!.story!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          if (tarotCardInfo.mythology != null) ...[
            const SizedBox(height: 32),
            Text(
              '신화적 연결',
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
                tarotCardInfo.mythology!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],

          if (tarotCardInfo.historicalContext != null) ...[
            const SizedBox(height: 32),
            Text(
              '역사적 배경',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  DSColors.success.withValues(alpha: 0.1),
                  DSColors.accent.withValues(alpha: 0.1)
                ],
              ),
              child: Text(
                tarotCardInfo.historicalContext!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ]
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
