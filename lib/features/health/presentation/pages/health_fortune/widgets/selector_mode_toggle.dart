import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';

class SelectorModeToggle extends StatelessWidget {
  final bool useGridSelector;
  final ValueChanged<bool> onChanged;

  const SelectorModeToggle({
    super.key,
    required this.useGridSelector,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              icon: Icons.grid_view_rounded,
              label: '목록 선택',
              isSelected: useGridSelector,
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(true);
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              icon: Icons.person_outline_rounded,
              label: '실루엣 선택',
              isSelected: !useGridSelector,
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TossDesignSystem.white : TossDesignSystem.white.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? TossTheme.primaryBlue
                  : TossTheme.textGray600,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TossTheme.body3.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? TossTheme.primaryBlue
                    : TossTheme.textGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
