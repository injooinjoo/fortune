import 'package:flutter/material.dart';
import '../../../../../../core/theme/fortune_theme.dart';

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
            TossTheme.primaryBlue.withValues(alpha: 0.1),
            TossTheme.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TossTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '내일 건강 미리보기',
                style: TossTheme.heading3.copyWith(
                  color: TossTheme.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            tomorrowPreview,
            style: TossTheme.body2.copyWith(
              color: TossTheme.textBlack,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
