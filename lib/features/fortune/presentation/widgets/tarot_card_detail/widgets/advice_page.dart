import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

class AdvicePage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;

  const AdvicePage({
    super.key,
    required this.cardInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '실천 조언',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TossDesignSystem.spacingM),

          // Main advice
          if (cardInfo['advice'] != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingL),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                  TossDesignSystem.warningOrange.withValues(alpha: 0.1)
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 48,
                    color: TossDesignSystem.warningOrange,
                  ),
                  const SizedBox(height: TossDesignSystem.spacingM),
                  Text(
                    cardInfo['advice'],
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacingXL)
          ],

          // Questions for reflection
          if (cardInfo['questions'] != null) ...[
            _buildSectionTitle(context, '성찰을 위한 질문'),
            const SizedBox(height: TossDesignSystem.spacingM),
            ...(cardInfo['questions'] as List).map((question) {
              return Container(
                margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                padding: const EdgeInsets.all(TossDesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: TossDesignSystem.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  border: Border.all(
                    color: TossDesignSystem.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: TossDesignSystem.primaryBlue,
                    ),
                    const SizedBox(width: TossDesignSystem.spacingS),
                    Expanded(
                      child: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
