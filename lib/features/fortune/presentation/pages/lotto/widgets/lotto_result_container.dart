import 'package:flutter/material.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';
import 'lotto_numbers_card.dart';
import 'lotto_pension_card.dart';
import 'lotto_location_card.dart';
import 'lotto_timing_card.dart';
import 'lotto_saju_card.dart';

/// 로또 결과 전체 컨테이너
///
/// 모든 로또 운세 결과 섹션을 표시합니다:
/// 1. 로또 6/45 행운 번호 (5+1)
/// 2. 연금복권 720+ (조 블러)
/// 3. 행운의 구매 장소
/// 4. 최적 구매 타이밍
/// 5. 사주 기반 조언
/// 6. 행운의 팁
class LottoResultContainer extends StatelessWidget {
  final LottoFortuneResult result;
  final bool isPremiumUnlocked;
  final VoidCallback? onUnlockPressed;
  final String? currentLocationName;

  const LottoResultContainer({
    super.key,
    required this.result,
    this.isPremiumUnlocked = false,
    this.onUnlockPressed,
    this.currentLocationName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 로또 6/45 행운 번호 카드 (메인)
        LottoNumbersCard(
          lottoResult: result.lottoResult,
          isPremiumUnlocked: isPremiumUnlocked,
          onUnlockPressed: onUnlockPressed,
        ),
        const SizedBox(height: 16),

        // 2. 연금복권 720+ 카드
        LottoPensionCard(
          pensionResult: result.pensionResult,
          isGroupUnlocked: isPremiumUnlocked,
          onUnlockPressed: onUnlockPressed,
        ),
        const SizedBox(height: 16),

        // 3. 행운의 구매 장소
        LottoLocationCard(
          luckyLocation: result.luckyLocation,
          currentLocationName: currentLocationName,
        ),
        const SizedBox(height: 16),

        // 4. 최적 구매 타이밍
        LottoTimingCard(
          luckyTiming: result.luckyTiming,
        ),
        const SizedBox(height: 16),

        // 5. 사주 기반 조언
        LottoSajuCard(
          sajuAdvice: result.sajuAdvice,
        ),
        const SizedBox(height: 16),

        // 6. 행운의 팁
        _buildLuckyTips(context, isDark),
        const SizedBox(height: 16),

        // 7. 면책 조항
        _buildDisclaimer(isDark),
      ],
    );
  }

  Widget _buildLuckyTips(BuildContext context, bool isDark) {
    return HanjiCard(
      style: HanjiCardStyle.minimal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  color: ObangseokColors.hwang,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '행운의 팁',
                  style: TypographyUnified.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? ObangseokColors.baekDark
                        : ObangseokColors.meok,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              context,
              isDark,
              icon: Icons.color_lens_outlined,
              title: '번호대별 색상',
              description: '1-10 노랑, 11-20 파랑, 21-30 빨강, 31-40 회색, 41-45 초록',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              context,
              isDark,
              icon: Icons.shopping_cart_outlined,
              title: '구매 팁',
              description: '직감이 끌리는 번호를 선택하고, 긍정적인 마음으로 구매하세요',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              context,
              isDark,
              icon: Icons.pie_chart_outline,
              title: '당첨 확률',
              description: '로또 1등 당첨 확률은 약 1/8,145,060 입니다',
            ),
            const SizedBox(height: 10),
            _buildTipItem(
              context,
              isDark,
              icon: Icons.casino_outlined,
              title: '로또 추첨일',
              description: '매주 토요일 오후 8시 45분 MBC에서 생방송 추첨',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? ObangseokColors.hwang.withValues(alpha: 0.1)
                : ObangseokColors.hwang.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: ObangseokColors.hwang,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TypographyUnified.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TypographyUnified.bodySmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                      : ObangseokColors.meok.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.meok.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: isDark
                ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                : ObangseokColors.meok.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '본 서비스는 재미와 오락 목적으로 제공됩니다. 로또 번호는 무작위로 추첨되며, '
              '사주 기반 번호가 당첨을 보장하지 않습니다. 무리한 복권 구매는 삼가해 주세요.',
              style: TypographyUnified.labelSmall.copyWith(
                color: isDark
                    ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                    : ObangseokColors.meok.withValues(alpha: 0.4),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
