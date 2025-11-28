import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class CognitiveFunctionsCard extends StatelessWidget {
  const CognitiveFunctionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology,
                size: 20,
                color: TossDesignSystem.tossBlue),
              const SizedBox(width: 8),
              Text(
                '인지 기능 분석',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '인지 기능 차트',
                style: TextStyle(
                  color: TossDesignSystem.gray500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
