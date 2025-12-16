import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../tarot_card_helpers.dart';

class CardDetailModal extends StatelessWidget {
  final int cardIndex;
  final String position;
  final String interpretation;

  const CardDetailModal({
    super.key,
    required this.cardIndex,
    required this.position,
    required this.interpretation,
  });

  static void show({
    required BuildContext context,
    required int cardIndex,
    required String position,
    required String interpretation,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDetailModal(
        cardIndex: cardIndex,
        position: position,
        interpretation: interpretation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = TarotCardHelpers.getCardImagePath(cardIndex);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              position,
              style: DSTypography.bodyLarge.copyWith(
                color: const Color(0xFF9333EA),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/images/tarot/$imagePath'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '해석',
              style: DSTypography.headingSmall.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              interpretation,
              style: DSTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
