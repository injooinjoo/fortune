import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

class CardImagePage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;
  final String imagePath;
  final Animation<double> scaleAnimation;

  const CardImagePage({
    super.key,
    required this.cardInfo,
    required this.imagePath,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.all(TossDesignSystem.spacingL),
        child: Column(
          children: [
            // Card image
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(TossDesignSystem.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: TossDesignSystem.purple.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(TossDesignSystem.radiusL),
                    child: Image.asset(
                      'assets/images/tarot/$imagePath',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: TossDesignSystem.spacingL),

            // Basic info
            GlassContainer(
              padding: const EdgeInsets.all(TossDesignSystem.spacingS),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.1),
                  TossDesignSystem.primaryBlue.withValues(alpha: 0.1)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    context: context,
                    icon: Icons.local_fire_department,
                    label: '원소',
                    value: cardInfo['element'] ?? 'Unknown',
                  ),
                  if (cardInfo['astrology'] != null)
                    _buildInfoItem(
                      context: context,
                      icon: Icons.stars,
                      label: '점성술',
                      value: cardInfo['astrology'],
                    ),
                  if (cardInfo['numerology'] != null)
                    _buildInfoItem(
                      context: context,
                      icon: Icons.looks_one,
                      label: '수비학',
                      value: cardInfo['numerology'].toString(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: TossDesignSystem.purple, size: 24),
        const SizedBox(height: TossDesignSystem.spacingXXS),
        Text(
          label,
          style: TextStyle(
            color: TossDesignSystem.white.withValues(alpha: 0.7),
            fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
        ),
        const SizedBox(height: 4 * 0.5),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
