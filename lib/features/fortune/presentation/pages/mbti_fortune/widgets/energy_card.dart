import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/design_system/design_system.dart';

class EnergyCard extends StatelessWidget {
  final double energyLevel;
  final List<Color> colors;

  const EnergyCard({
    super.key,
    required this.energyLevel,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full,
                size: 20,
                color: colors.first),
              const SizedBox(width: 8),
              Text(
                '오늘의 에너지 레벨',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: themeColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: energyLevel,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(energyLevel * 100).toInt()}% 충전됨',
            style: DSTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.first,
            ),
          ),
        ],
      ),
    );
  }
}
