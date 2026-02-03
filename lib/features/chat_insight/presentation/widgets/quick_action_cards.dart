import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 빈 화면에서 표시되는 3개 Quick Action 카드
class QuickActionCards extends StatelessWidget {
  final VoidCallback onPasteTap;
  final VoidCallback onFileTap;
  final VoidCallback onSampleTap;

  const QuickActionCards({
    super.key,
    required this.onPasteTap,
    required this.onFileTap,
    required this.onSampleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.content_paste,
            label: '카톡\n대화\n붙여넣기',
            onTap: onPasteTap,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: _ActionCard(
            icon: Icons.upload_file,
            label: '파일\n(.txt)\n업로드',
            onTap: onFileTap,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: _ActionCard(
            icon: Icons.auto_awesome,
            label: '샘플로\n체험\n하기',
            onTap: onSampleTap,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.accent, size: 28),
            const SizedBox(height: DSSpacing.sm),
            Text(
              label,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
