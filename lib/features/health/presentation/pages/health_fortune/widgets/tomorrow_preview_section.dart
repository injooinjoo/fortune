import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

class TomorrowPreviewSection extends StatelessWidget {
  final String tomorrowPreview;

  const TomorrowPreviewSection({
    super.key,
    required this.tomorrowPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.accent.withValues(alpha: 0.1),
            DSColors.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '내일 건강 미리보기',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tomorrowPreview,
            style: context.heading3.copyWith(
              color: context.colors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
