import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '실천 조언',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Main advice
          if (cardInfo['advice'] != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                colors: [
                  DSColors.warning.withValues(alpha: 0.1),
                  DSColors.warning.withValues(alpha: 0.1)
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    size: 48,
                    color: DSColors.warning,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cardInfo['advice'],
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const SizedBox(height: 32)
          ],

          // Questions for reflection
          if (cardInfo['questions'] != null) ...[
            _buildSectionTitle(context, '성찰을 위한 질문'),
            const SizedBox(height: 16),
            ...(cardInfo['questions'] as List).map((question) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSRadius.md),
                  border: Border.all(
                    color: DSColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 20,
                      color: DSColors.accent,
                    ),
                    const SizedBox(width: 8),
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
