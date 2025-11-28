import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
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
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드의 이야기',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TossDesignSystem.spacingL),

          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.purple.withValues(alpha: 0.1),
                TossDesignSystem.primaryBlue.withValues(alpha: 0.1)
              ],
            ),
            child: Text(
              tarotCardInfo!.story!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          if (tarotCardInfo.mythology != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '신화적 연결',
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
                tarotCardInfo.mythology!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],

          if (tarotCardInfo.historicalContext != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '역사적 배경',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen.withValues(alpha: 0.1),
                  TossDesignSystem.primaryBlue.withValues(alpha: 0.1)
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
