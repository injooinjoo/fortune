import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fortune_card.dart';
import 'fortune_explanation_bottom_sheet.dart';

class FortuneCardWithInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String fortuneType;
  final VoidCallback onTap;
  final String? badge;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? emoji;
  final List<Color>? gradient;
  final bool showInfoButton;

  const FortuneCardWithInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.fortuneType,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.backgroundColor,
    this.emoji,
    this.gradient,
    this.showInfoButton = true,
  });

  void _showFortuneInfo(BuildContext context) {
    HapticFeedback.lightImpact();
    FortuneExplanationBottomSheet.show(
      context,
      fortuneType: fortuneType,
      onFortuneButtonPressed: () {
        // Navigate to fortune screen when button is pressed
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FortuneCard(
          icon: icon,
          title: title,
          description: description,
          onTap: onTap,
          badge: badge,
          iconColor: iconColor,
          backgroundColor: backgroundColor,
          emoji: emoji,
          gradient: gradient,
        ),
        if (showInfoButton)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFortuneInfo(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: gradient?.first ?? iconColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}