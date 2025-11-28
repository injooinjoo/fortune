import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../tarot_card_helpers.dart';

class MiniCardWidget extends StatelessWidget {
  final int index;
  final int cardIndex;
  final double fontScale;
  final VoidCallback onTap;

  const MiniCardWidget({
    super.key,
    required this.index,
    required this.cardIndex,
    required this.fontScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = TarotCardHelpers.getCardImagePath(cardIndex);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced card with hover effect
              Hero(
                tag: 'card_$index',
                child: Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: AssetImage('assets/images/tarot/$imagePath'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: TossDesignSystem.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TossDesignSystem.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TypographyUnified.labelTiny.copyWith(
                    fontSize: TypographyUnified.labelTiny.fontSize! * fontScale,
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
