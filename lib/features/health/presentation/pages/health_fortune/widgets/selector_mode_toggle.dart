import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/utils/haptic_utils.dart';

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
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              context: context,
              icon: Icons.grid_view_rounded,
              label: '목록 선택',
              isSelected: useGridSelector,
              onTap: () {
                HapticUtils.selection();
                onChanged(true);
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              context: context,
              icon: Icons.person_outline_rounded,
              label: '실루엣 선택',
              isSelected: !useGridSelector,
              onTap: () {
                HapticUtils.selection();
                onChanged(false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required BuildContext context,
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
          color: isSelected
              ? context.colors.surface
              : context.colors.surface.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? context.colors.accent
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.buttonMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? context.colors.accent
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
