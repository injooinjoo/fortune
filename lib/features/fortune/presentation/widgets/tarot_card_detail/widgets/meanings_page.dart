import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

class MeaningsPage extends StatelessWidget {
  final Map<String, dynamic> cardInfo;

  const MeaningsPage({
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
            '카드의 의미',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Upright meaning
          if (cardInfo['uprightMeaning'] != null) ...[
            _buildMeaningCard(
              context: context,
              title: '정방향',
              meaning: cardInfo['uprightMeaning'],
              icon: Icons.arrow_upward,
              color: DSColors.success,
            ),
            const SizedBox(height: 16)
          ],

          // Reversed meaning
          if (cardInfo['reversedMeaning'] != null) ...[
            _buildMeaningCard(
              context: context,
              title: '역방향',
              meaning: cardInfo['reversedMeaning'],
              icon: Icons.arrow_downward,
              color: DSColors.warning,
            ),
            const SizedBox(height: 16)
          ],

          // Related cards
          if (cardInfo['relatedCards'] != null) ...[
            _buildSectionTitle(context, '관련 카드'),
            const SizedBox(height: 8),
            ...cardInfo['relatedCards'].map<Widget>(
              (card) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.link,
                        size: 16, color: DSColors.accentSecondary),
                    const SizedBox(width: 8),
                    Text(
                      card,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildMeaningCard({
    required BuildContext context,
    required String title,
    required String meaning,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
