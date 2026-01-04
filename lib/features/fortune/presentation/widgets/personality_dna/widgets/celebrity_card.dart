import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 유명인 닮은꼴 카드
class CelebrityCard extends StatelessWidget {
  final Celebrity celebrity;

  // 테마 색상 상수
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _orangeColor = Color(0xFFFFA500);

  const CelebrityCard({super.key, required this.celebrity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldColor.withValues(alpha: isDark ? 0.15 : 0.1),
            _orangeColor.withValues(alpha: isDark ? 0.15 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goldColor.withValues(alpha: isDark ? 0.6 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎬', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '유명인 닮은꼴',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Container(
            padding: const EdgeInsets.all(DSSpacing.cardPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _goldColor.withValues(alpha: isDark ? 0.3 : 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 별 아이콘 대신 그라데이션 원형 배경에 ⭐ 이모지
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_goldColor, _orangeColor],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _goldColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⭐', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        celebrity.name,
                        style: context.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        celebrity.reason,
                        style: context.bodyMedium.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: isDark ? 0.85 : 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
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
