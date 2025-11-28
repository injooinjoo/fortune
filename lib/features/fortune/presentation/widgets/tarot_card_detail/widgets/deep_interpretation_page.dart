import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/constants/tarot_metadata.dart';

class DeepInterpretationPage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final int cardIndex;

  const DeepInterpretationPage({
    super.key,
    required this.cardInfo,
    required this.cardIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tarotCardInfo =
        cardIndex < 22 ? TarotMetadata.majorArcana[cardIndex] : null;

    if (tarotCardInfo?.psychologicalMeaning == null &&
        tarotCardInfo?.spiritualMeaning == null) {
      return _buildComingSoonPage(context, '심화 해석', '곧 업데이트됩니다');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tarotCardInfo?.psychologicalMeaning != null) ...[
            Text(
              '심리학적 해석',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.1),
                  TossDesignSystem.purple.withValues(alpha: 0.1)
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 48,
                    color: TossDesignSystem.purple,
                  ),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    tarotCardInfo!.psychologicalMeaning!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],

          if (tarotCardInfo?.spiritualMeaning != null) ...[
            const SizedBox(height: TossDesignSystem.spacingXL),
            Text(
              '영적 의미',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TossDesignSystem.spacingM),
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
                  TossDesignSystem.purple.withValues(alpha: 0.1)
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.self_improvement,
                    size: 48,
                    color: TossDesignSystem.primaryBlue,
                  ),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    tarotCardInfo!.spiritualMeaning!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
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
