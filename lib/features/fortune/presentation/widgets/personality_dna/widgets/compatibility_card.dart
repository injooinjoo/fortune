import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/personality_dna_model.dart';

/// 궁합 카드
class CompatibilityCard extends StatelessWidget {
  final Compatibility compatibility;

  // 테마 색상 상수
  static const Color _compatibilityColor = DSColors.accentSecondary;

  const CompatibilityCard({super.key, required this.compatibility});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _compatibilityColor.withValues(alpha: isDark ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💞', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '나와 잘 맞는 유형',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildCompatibilityItem(
                  context,
                  isDark,
                  '👫',
                  '친구',
                  compatibility.friend,
                  const Color(0xFF3498DB), // 고유 색상 - 친구 파란색
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildCompatibilityItem(
                  context,
                  isDark,
                  '💕',
                  '연인',
                  compatibility.lover,
                  DSColors.accentSecondary,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: _buildCompatibilityItem(
                  context,
                  isDark,
                  '🤝',
                  '동료',
                  compatibility.colleague,
                  const Color(0xFF2ECC71), // 고유 색상 - 동료 초록색
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityItem(
    BuildContext context,
    bool isDark,
    String emoji,
    String label,
    CompatibilityType type,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
      ),
      child: Column(
        children: [
          // MBTI 캐릭터 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/mbti/${type.mbti.toLowerCase()}.webp',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type.mbti,
              style: context.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            type.description,
            style: context.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.9 : 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
