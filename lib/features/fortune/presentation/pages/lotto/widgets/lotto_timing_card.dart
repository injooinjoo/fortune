import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 최적 구매 타이밍 카드
///
/// 사주 기반 행운의 요일과 시간대를 추천합니다.
class LottoTimingCard extends StatelessWidget {
  final LuckyTiming luckyTiming;

  const LottoTimingCard({
    super.key,
    required this.luckyTiming,
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

            // 추천 구매일
            _buildRecommendedDate(isDark),
            const SizedBox(height: 16),

            // 요일 & 시간대 그리드
            _buildTimingGrid(isDark),
            const SizedBox(height: 16),

            // 피해야 할 시간
            _buildAvoidTime(isDark),
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
            color: ObangseokColors.jeok.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: ObangseokColors.jeok,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최적 구매 타이밍',
                style: TypographyUnified.heading4.copyWith(
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '오행 기운이 가장 강한 시간',
                style: TypographyUnified.labelSmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                      : ObangseokColors.meok.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedDate(bool isDark) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final formattedDate = dateFormat.format(luckyTiming.recommendedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ObangseokColors.jeok.withValues(alpha: 0.15),
            ObangseokColors.hwang.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ObangseokColors.jeok.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? ObangseokColors.meok.withValues(alpha: 0.5)
                  : ObangseokColors.baek,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: ObangseokColors.jeok,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이번 주 추천 구매일',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                        : ObangseokColors.meok.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TypographyUnified.heading4.copyWith(
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.w700,
                    color: ObangseokColors.jeok,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ObangseokColors.jeok.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '추천',
              style: TypographyUnified.labelSmall.copyWith(
                color: ObangseokColors.jeok,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingGrid(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildTimingItem(
            isDark,
            icon: Icons.today_rounded,
            title: '행운의 요일',
            value: luckyTiming.luckyDay,
            reason: luckyTiming.dayReason,
            color: ObangseokColors.hwang,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingItem(
            isDark,
            icon: Icons.access_time_rounded,
            title: '행운의 시간',
            value: luckyTiming.luckyTimeSlot,
            reason: luckyTiming.timeReason,
            color: ObangseokColors.cheong,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingItem(
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    required String reason,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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
                color: color,
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
            reason,
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

  Widget _buildAvoidTime(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.4)
            : ObangseokColors.meok.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: isDark
                ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                : ObangseokColors.meok.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Text(
            '피해야 할 시간: ',
            style: TypographyUnified.labelSmall.copyWith(
              color: isDark
                  ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                  : ObangseokColors.meok.withValues(alpha: 0.4),
            ),
          ),
          Text(
            luckyTiming.avoidTimeSlot,
            style: TypographyUnified.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                  : ObangseokColors.meok.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
