import 'package:flutter/material.dart';
import '../../../../../../core/theme/font_config.dart';
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
                currentLocationName != null
                    ? '$currentLocationName 행운의 구매 장소'
                    : '행운의 구매 장소',
                style: TypographyUnified.heading4.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
                    fontFamily: FontConfig.primary,
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
      child: Row(
        children: [
          const Icon(
            Icons.palette_rounded,
            size: 20,
            color: ObangseokColors.cheong,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '행운의 간판색',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                        : ObangseokColors.meok.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${luckyLocation.luckySignColor} 간판이 있는 곳을 찾아보세요',
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ObangseokColors.baekDark
                        : ObangseokColors.meok,
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
