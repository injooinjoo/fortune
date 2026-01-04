import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 직장 스타일 카드
class WorkStyleCard extends StatelessWidget {
  final WorkStyle workStyle;

  // 테마 색상 상수
  static const Color _workColor = Color(0xFF4A90E2);

  const WorkStyleCard({super.key, required this.workStyle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _workColor.withValues(alpha: isDark ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💼', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '직장 스타일',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 타이틀
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF67B8F5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              workStyle.title,
              style: context.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          // 상세 정보
          _buildDetailItem(context, isDark, '👔 상사일 때', workStyle.asBoss),
          const SizedBox(height: DSSpacing.sm),
          _buildDetailItem(
              context, isDark, '🍻 회식에서', workStyle.atCompanyDinner),
          const SizedBox(height: DSSpacing.sm),
          _buildDetailItem(context, isDark, '📝 업무 습관', workStyle.workHabit),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    bool isDark,
    String label,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _workColor.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: _workColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            content,
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}
