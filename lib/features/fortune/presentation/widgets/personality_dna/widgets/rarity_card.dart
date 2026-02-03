import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 희귀도 카드
class RarityCard extends StatelessWidget {
  final int? popularityRank;
  final String mbti;

  const RarityCard({
    super.key,
    this.popularityRank,
    required this.mbti,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rarityData = _getRarityData();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rarityData.color.withValues(alpha: isDark ? 0.15 : 0.1),
            rarityData.color.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rarityData.color.withValues(alpha: isDark ? 0.6 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // MBTI 캐릭터 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/mbti/${mbti.toLowerCase()}.webp',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text(
                    '📊',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '희귀도',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              // 희귀도 배지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      rarityData.color,
                      rarityData.color.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: rarityData.color.withValues(alpha: isDark ? 0.4 : 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  rarityData.tier,
                  style: context.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // 순위 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rarityData.rankText,
                    style: context.heading3.copyWith(
                      color: rarityData.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rarityData.description,
                    style: context.labelLarge.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: isDark ? 0.75 : 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 진행바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rarityData.percentage / 100,
              backgroundColor: rarityData.color.withValues(alpha: isDark ? 0.3 : 0.2),
              valueColor: AlwaysStoppedAnimation(rarityData.color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '전국 $mbti 유형 중 상위 ${rarityData.percentage.toStringAsFixed(1)}%',
            style: context.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.75 : 0.6),
            ),
          ),
        ],
      ),
    );
  }

  _RarityData _getRarityData() {
    if (popularityRank == null) {
      return _RarityData(
        tier: 'COMMON',
        color: const Color(0xFF95A5A6), // 고유 색상 - COMMON 회색
        percentage: 50.0,
        rankText: '일반',
        description: '평범한 조합',
      );
    }

    if (popularityRank! <= 5) {
      return _RarityData(
        tier: 'LEGENDARY',
        color: DSFortuneColors.fortuneGoldMuted,
        percentage: (popularityRank! / 60 * 100),
        rankText: 'TOP $popularityRank',
        description: '전설적인 조합!',
      );
    } else if (popularityRank! <= 15) {
      return _RarityData(
        tier: 'EPIC',
        color: DSFortuneColors.mysticalPurpleMuted,
        percentage: (popularityRank! / 60 * 100),
        rankText: '$popularityRank위',
        description: '희귀한 조합',
      );
    } else if (popularityRank! <= 30) {
      return _RarityData(
        tier: 'RARE',
        color: const Color(0xFF3498DB), // 고유 색상 - RARE 파란색
        percentage: (popularityRank! / 60 * 100),
        rankText: '$popularityRank위',
        description: '특별한 조합',
      );
    } else if (popularityRank! <= 45) {
      return _RarityData(
        tier: 'UNCOMMON',
        color: const Color(0xFF2ECC71), // 고유 색상 - UNCOMMON 초록색
        percentage: (popularityRank! / 60 * 100),
        rankText: '$popularityRank위',
        description: '독특한 조합',
      );
    } else {
      return _RarityData(
        tier: 'COMMON',
        color: const Color(0xFF95A5A6), // 고유 색상 - COMMON 회색
        percentage: (popularityRank! / 60 * 100),
        rankText: '$popularityRank위',
        description: '일반적인 조합',
      );
    }
  }
}

class _RarityData {
  final String tier;
  final Color color;
  final double percentage;
  final String rankText;
  final String description;

  _RarityData({
    required this.tier,
    required this.color,
    required this.percentage,
    required this.rankText,
    required this.description,
  });
}
