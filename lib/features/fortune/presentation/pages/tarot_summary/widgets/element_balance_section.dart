import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../../core/constants/tarot/tarot_helper.dart';

class ElementBalanceSection extends StatelessWidget {
  final double fontScale;
  final Map<String, dynamic> elementBalance;
  final String? dominantElement;

  const ElementBalanceSection({
    super.key,
    required this.fontScale,
    required this.elementBalance,
    this.dominantElement,
  });

  @override
  Widget build(BuildContext context) {
    final total = elementBalance.values.fold<int>(0, (sum, count) => sum + (count as int));

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '원소 균형',
            style: DSTypography.headingSmall.copyWith(
              fontSize: DSTypography.headingSmall.fontSize! * fontScale,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...elementBalance.entries.map((entry) {
            final percentage = ((entry.value as int) / total * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    TarotHelper.getElementIcon(entry.key),
                    size: 24,
                    color: TarotHelper.getElementColor(entry.key),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      entry.key,
                      style: DSTypography.bodySmall.copyWith(
                        fontSize: DSTypography.bodySmall.fontSize! * fontScale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: percentage / 100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TarotHelper.getElementColor(entry.key),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: DSTypography.bodySmall.copyWith(
                      fontSize: DSTypography.bodySmall.fontSize! * fontScale,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (dominantElement != null) ...[
            SizedBox(height: 12),
            Text(
              '$dominantElement 원소가 우세합니다',
              style: DSTypography.bodySmall.copyWith(
                fontSize: DSTypography.bodySmall.fontSize! * fontScale,
                color: const Color(0xFF9333EA).withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
