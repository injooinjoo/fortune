import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// MBTI 인지 기능 분석 카드 (강점 & 도전과제)
class CognitiveFunctionsCard extends StatelessWidget {
  final List<String> strengths;
  final List<String> challenges;

  const CognitiveFunctionsCard({
    super.key,
    required this.strengths,
    required this.challenges,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 데이터가 없으면 표시 안함
    if (strengths.isEmpty && challenges.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '인지 기능 분석',
                style: DSTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 강점 섹션
          if (strengths.isNotEmpty) ...[
            _buildSection(
              context,
              title: '인지적 강점',
              icon: Icons.trending_up,
              iconColor: const Color(0xFF10B981),
              items: strengths,
            ),
            if (challenges.isNotEmpty) const SizedBox(height: 16),
          ],

          // 도전과제 섹션
          if (challenges.isNotEmpty)
            _buildSection(
              context,
              title: '성장 포인트',
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFFF59E0B),
              items: challenges,
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: DSTypography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildChip(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String text) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        style: DSTypography.labelSmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
