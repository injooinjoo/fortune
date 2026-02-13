import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../domain/models/health_fortune_model.dart';

class BodyPartHealthSection extends StatelessWidget {
  final List<BodyPartHealth> bodyPartHealthList;
  final List<BodyPart> selectedBodyParts;

  const BodyPartHealthSection({
    super.key,
    required this.bodyPartHealthList,
    required this.selectedBodyParts,
  });

  @override
  Widget build(BuildContext context) {
    final concernedParts = bodyPartHealthList
        .where((bph) => selectedBodyParts.contains(bph.bodyPart))
        .toList();

    if (concernedParts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관심 부위 상태',
            style: context.heading3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ...concernedParts.map((bph) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(bph.level.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(bph.level.colorValue).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bph.bodyPart.displayName,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(bph.level.colorValue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bph.score}점',
                          style: context.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bph.description,
                    style: context.buttonMedium.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
