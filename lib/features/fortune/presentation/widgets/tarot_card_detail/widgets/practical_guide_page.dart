import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/constants/tarot_metadata.dart';

class PracticalGuidePage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final int cardIndex;

  const PracticalGuidePage({
    super.key,
    required this.cardInfo,
    required this.cardIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tarotCardInfo =
        cardIndex < 22 ? TarotMetadata.majorArcana[cardIndex] : null;

    if (tarotCardInfo?.dailyApplications == null &&
        tarotCardInfo?.meditation == null &&
        tarotCardInfo?.affirmations == null) {
      return _buildComingSoonPage(context, '실천 가이드', '곧 업데이트됩니다');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tarotCardInfo?.dailyApplications != null) ...[
            Text(
              '일상 적용법',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...tarotCardInfo!.dailyApplications!.map(
              (application) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(8),
                  gradient: LinearGradient(
                    colors: [
                      DSColors.success.withValues(alpha: 0.1),
                      DSColors.success.withValues(alpha: 0.1)
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: DSColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          application,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (tarotCardInfo?.meditation != null) ...[
            const SizedBox(height: 32),
            Text(
              '명상 가이드',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  DSColors.accent.withValues(alpha: 0.1),
                  DSColors.accent.withValues(alpha: 0.1)
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.spa,
                    size: 48,
                    color: DSColors.accent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tarotCardInfo!.meditation!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
          if (tarotCardInfo?.affirmations != null) ...[
            const SizedBox(height: 32),
            Text(
              '확언문',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...tarotCardInfo!.affirmations!.map(
              (affirmation) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(8),
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accentSecondary.withValues(alpha: 0.1),
                      DSColors.accentSecondary.withValues(alpha: 0.1)
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '"$affirmation"',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
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
