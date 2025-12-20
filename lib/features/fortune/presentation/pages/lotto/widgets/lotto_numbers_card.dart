import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 로또 번호 카드 (5+1 구조)
///
/// 6개 번호 중 5개는 바로 공개, 1개는 광고 후 공개
class LottoNumbersCard extends StatelessWidget {
  final LottoResult lottoResult;
  final bool isPremiumUnlocked;
  final VoidCallback? onUnlockPressed;

  const LottoNumbersCard({
    super.key,
    required this.lottoResult,
    this.isPremiumUnlocked = false,
    this.onUnlockPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HanjiCard(
      colorScheme: HanjiColorScheme.luck,
      style: HanjiCardStyle.elevated,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(isDark),
            const SizedBox(height: 20),

            // 운세 메시지
            _buildFortuneMessage(isDark),
            const SizedBox(height: 24),

            // 번호들 (5 + 1)
            _buildNumbersRow(context, isDark),
            const SizedBox(height: 16),

            // 번호 색상 안내
            _buildColorGuide(isDark),

            // 잠금 해제 버튼 (잠겨있을 때만)
            if (!isPremiumUnlocked) ...[
              const SizedBox(height: 16),
              Center(
                child: UnlockPremiumButton(onPressed: onUnlockPressed),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ObangseokColors.hwang,
                ObangseokColors.hwangLight,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ObangseokColors.hwang.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.casino_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 행운 번호',
                style: TypographyUnified.heading3.copyWith(
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '사주 기반 맞춤 번호 6개',
                style: TypographyUnified.bodySmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                      : ObangseokColors.meok.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.hwang.withValues(alpha: 0.1)
            : ObangseokColors.hwang.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ObangseokColors.hwang.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: ObangseokColors.hwang,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lottoResult.fortuneMessage,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isDark
                    ? ObangseokColors.baekDark
                    : ObangseokColors.meok,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersRow(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? ObangseokColors.baek.withValues(alpha: 0.1)
              : ObangseokColors.meok.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 5개 공개 번호
          ...lottoResult.visibleNumbers.map((number) => _buildNumberBall(
                number,
                isDark,
                isLocked: false,
              )),
          // 1개 잠금 번호
          _buildNumberBall(
            lottoResult.lockedNumber,
            isDark,
            isLocked: !isPremiumUnlocked,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberBall(int number, bool isDark, {required bool isLocked}) {
    final ballColor = Color(LottoNumberGenerator.getNumberColor(number));

    final ball = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ballColor.withValues(alpha: 0.9),
            ballColor,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ballColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TypographyUnified.numberMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );

    if (isLocked) {
      return GestureDetector(
        onTap: onUnlockPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 블러된 번호
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: ball,
            ),
            // 자물쇠 오버레이
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ObangseokColors.hwang.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ObangseokColors.hwang,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: ObangseokColors.hwang,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }

    return ball;
  }

  Widget _buildColorGuide(bool isDark) {
    final colorGuides = [
      {'range': '1-10', 'color': const Color(0xFFFFC107), 'name': '노랑'},
      {'range': '11-20', 'color': const Color(0xFF2196F3), 'name': '파랑'},
      {'range': '21-30', 'color': const Color(0xFFE91E63), 'name': '빨강'},
      {'range': '31-40', 'color': const Color(0xFF9E9E9E), 'name': '회색'},
      {'range': '41-45', 'color': const Color(0xFF4CAF50), 'name': '초록'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.2)
            : ObangseokColors.baek.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 8,
        runSpacing: 6,
        children: colorGuides.map((guide) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: guide['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                guide['range'] as String,
                style: TypographyUnified.labelSmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                      : ObangseokColors.meok.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 프리미엄 번호 잠금 해제 버튼
class UnlockPremiumButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const UnlockPremiumButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ObangseokColors.hwang,
              ObangseokColors.hwangLight,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4DFFC107),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '광고 보고 마지막 번호 확인',
              style: TypographyUnified.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
