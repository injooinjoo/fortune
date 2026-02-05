import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../domain/models/health_fortune_model.dart';

class ConditionOption extends StatelessWidget {
  final ConditionState condition;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const ConditionOption({
    super.key,
    required this.condition,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accent.withValues(alpha: 0.05)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? context.colors.accent : context.colors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? context.colors.accent : Colors.white.withValues(alpha: 0.0),
                border: isSelected ? null : Border.all(color: context.colors.border, width: 2),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.displayName,
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? context.colors.accent : context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getConditionDescription(condition),
                    style: context.buttonMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.arrow_forward_ios,
                color: context.colors.accent,
                size: 16,
              ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms)
      .fadeIn(duration: 500.ms)
      .slideX(begin: -0.1, end: 0);
  }

  String _getConditionDescription(ConditionState condition) {
    switch (condition) {
      case ConditionState.excellent:
        return '몸도 마음도 최상의 컨디션이에요';
      case ConditionState.good:
        return '전반적으로 좋은 상태예요';
      case ConditionState.normal:
        return '평상시와 비슷해요';
      case ConditionState.tired:
        return '조금 피곤하고 지쳐있어요';
      case ConditionState.sick:
        return '몸이 아프거나 컨디션이 안 좋아요';
    }
  }
}
