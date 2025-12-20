import 'package:flutter/material.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 행운의 구매 장소 추천 카드
///
/// 사주 기반 오행 방위와 추천 판매점 유형을 표시합니다.
class LottoLocationCard extends StatelessWidget {
  final LuckyLocation luckyLocation;
  final String? currentLocationName;

  const LottoLocationCard({
    super.key,
    required this.luckyLocation,
    this.currentLocationName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HanjiCard(
      style: HanjiCardStyle.elevated,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(isDark),
            const SizedBox(height: 20),

            // 위치 메시지
            _buildLocationMessage(isDark),
            const SizedBox(height: 20),

            // 정보 그리드
            _buildInfoGrid(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ObangseokColors.cheong.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: ObangseokColors.cheong,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '행운의 구매 장소',
                style: TypographyUnified.heading4.copyWith(
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              if (currentLocationName != null) ...[
                const SizedBox(height: 2),
                Text(
                  '$currentLocationName 기준',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                        : ObangseokColors.meok.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.cheong.withValues(alpha: 0.1)
            : ObangseokColors.cheong.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ObangseokColors.cheong.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildDirectionCompass(isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${luckyLocation.direction} 방향',
                  style: TypographyUnified.heading4.copyWith(
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.w700,
                    color: ObangseokColors.cheong,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  luckyLocation.directionDescription,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.8)
                        : ObangseokColors.meok.withValues(alpha: 0.7),
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

  Widget _buildDirectionCompass(bool isDark) {
    // 방위에 따른 아이콘 회전
    double rotation = 0;
    switch (luckyLocation.direction) {
      case '동쪽':
        rotation = 0.25; // 90도
        break;
      case '서쪽':
        rotation = 0.75; // 270도
        break;
      case '남쪽':
        rotation = 0.5; // 180도
        break;
      case '북쪽':
        rotation = 0; // 0도
        break;
      case '중앙':
        rotation = 0;
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.5)
            : ObangseokColors.baek,
        shape: BoxShape.circle,
        border: Border.all(
          color: ObangseokColors.cheong.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: luckyLocation.direction == '중앙'
          ? const Icon(
              Icons.adjust_rounded,
              color: ObangseokColors.cheong,
              size: 28,
            )
          : RotationTransition(
              turns: AlwaysStoppedAnimation(rotation),
              child: const Icon(
                Icons.navigation_rounded,
                color: ObangseokColors.cheong,
                size: 28,
              ),
            ),
    );
  }

  Widget _buildInfoGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                isDark,
                icon: Icons.store_rounded,
                title: '추천 판매점',
                value: luckyLocation.shopType,
                subtitle: luckyLocation.shopReason,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoItem(
                isDark,
                icon: Icons.palette_rounded,
                title: '행운의 간판색',
                value: luckyLocation.luckySignColor,
                subtitle: '이 색상의 간판이 있는 곳',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? ObangseokColors.baek.withValues(alpha: 0.1)
              : ObangseokColors.meok.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark
                    ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                    : ObangseokColors.meok.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TypographyUnified.labelSmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                      : ObangseokColors.meok.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? ObangseokColors.baekDark
                  : ObangseokColors.meok,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TypographyUnified.labelSmall.copyWith(
              color: isDark
                  ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                  : ObangseokColors.meok.withValues(alpha: 0.4),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
