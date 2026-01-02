import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 품종 맞춤 인사이트 카드
/// 품종별 특성, 건강 주의사항, 그루밍 팁을 보여줍니다.
class BreedIntelligenceCard extends StatelessWidget {
  final String breed;
  final String species;
  final String traitToday;
  final String healthWatch;
  final String groomingTip;
  final String petEmoji;

  const BreedIntelligenceCard({
    super.key,
    required this.breed,
    required this.species,
    required this.traitToday,
    required this.healthWatch,
    required this.groomingTip,
    required this.petEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.accent.withValues(alpha: 0.15),
                      colors.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(petEmoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            breed,
                            style: context.labelSmall.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          species,
                          style: context.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '맞춤 인사이트',
                      style: context.heading3.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 인사이트 항목들
          _buildInsightItem(
            context: context,
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFFF59E0B), // 골드
            title: '오늘의 특성',
            content: traitToday,
          ),
          const SizedBox(height: 14),
          _buildInsightItem(
            context: context,
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFEF4444), // 레드
            title: '건강 주의',
            content: healthWatch,
          ),
          const SizedBox(height: 14),
          _buildInsightItem(
            context: context,
            icon: Icons.spa_rounded,
            iconColor: const Color(0xFF10B981), // 그린
            title: '그루밍 팁',
            content: groomingTip,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.labelSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
