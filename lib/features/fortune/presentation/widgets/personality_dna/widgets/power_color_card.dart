import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 파워 컬러 카드
class PowerColorCard extends StatelessWidget {
  final PowerColor powerColor;

  const PowerColorCard({super.key, required this.powerColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: powerColor.color.withValues(alpha: isDark ? 0.7 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '나의 파워 컬러',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Container(
            padding: const EdgeInsets.all(DSSpacing.cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  powerColor.color,
                  powerColor.color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: powerColor.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 색상 원형
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: powerColor.color,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        powerColor.name,
                        style: context.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: DSSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          powerColor.hex.toUpperCase(),
                          style: context.labelLarge.copyWith(
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '이 색상은 당신의 에너지와 가장 잘 어울리는 파워 컬러입니다. 중요한 날이나 자신감이 필요할 때 이 색상을 활용해보세요!',
            style: context.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.85 : 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
