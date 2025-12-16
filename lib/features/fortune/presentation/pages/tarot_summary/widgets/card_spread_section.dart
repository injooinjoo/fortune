import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../../core/constants/tarot_metadata.dart';
import 'celtic_cross_layout.dart';
import 'horizontal_card_layout.dart';
import 'default_card_layout.dart';

class CardSpreadSection extends StatelessWidget {
  final double fontScale;
  final List<int> cards;
  final String spreadType;
  final Function(int) onCardTap;

  const CardSpreadSection({
    super.key,
    required this.fontScale,
    required this.cards,
    required this.spreadType,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF9333EA).withValues(alpha: 0.2),
          const Color(0xFF3182F6).withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        children: [
          Text(
            '카드 스프레드',
            style: DSTypography.headingSmall.copyWith(
              fontSize: DSTypography.headingSmall.fontSize! * fontScale,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildCardGrid(),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    final spreadLayout = TarotMetadata.spreads[spreadType]?.layout;

    if (spreadLayout == SpreadLayout.celticCross) {
      return CelticCrossLayout(
        cards: cards,
        fontScale: fontScale,
        onCardTap: onCardTap,
      );
    } else if (spreadLayout == SpreadLayout.horizontal) {
      return HorizontalCardLayout(
        cards: cards,
        fontScale: fontScale,
        onCardTap: onCardTap,
      );
    } else {
      return DefaultCardLayout(
        cards: cards,
        fontScale: fontScale,
        onCardTap: onCardTap,
      );
    }
  }
}
