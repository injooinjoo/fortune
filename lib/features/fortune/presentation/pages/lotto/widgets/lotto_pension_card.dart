import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../../../core/theme/font_config.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 연금복권 720+ 카드
///
/// 조 번호(1~5)는 블러 처리, 6자리 번호는 바로 공개
/// 광고 시청 후 조 번호 공개
class LottoPensionCard extends StatelessWidget {
  final PensionLotteryResult pensionResult;
  final bool isGroupUnlocked;
  final VoidCallback? onUnlockPressed;

  const LottoPensionCard({
    super.key,
    required this.pensionResult,
    this.isGroupUnlocked = false,
    this.onUnlockPressed,
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

            // 번호 영역
            _buildNumbersSection(isDark),
            const SizedBox(height: 16),

            // 운세 메시지
            _buildFortuneMessage(isDark),
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ObangseokColors.cheong,
                Color(0xFF5DADE2),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '연금복권 720+',
                style: TypographyUnified.heading4.copyWith(
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '매월 700만원 × 20년',
                style: TypographyUnified.labelSmall.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                      : ObangseokColors.meok.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        // 1등 당첨금 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ObangseokColors.cheong.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '1등 16.8억',
            style: TypographyUnified.labelSmall.copyWith(
              color: ObangseokColors.cheong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumbersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ObangseokColors.cheong.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // 조 번호 + 6자리 번호
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 조 번호 (블러 또는 공개)
              _buildGroupNumber(isDark),
              const SizedBox(width: 16),
              // 구분선
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.2)
                      : ObangseokColors.meok.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 16),
              // 6자리 번호
              ...pensionResult.numbers.map((number) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildDigit(number, isDark),
                  )),
            ],
          ),
          // 잠금 해제 버튼
          if (!isGroupUnlocked && onUnlockPressed != null) ...[
            const SizedBox(height: 16),
            _UnlockGroupButton(onPressed: onUnlockPressed!),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupNumber(bool isDark) {
    if (isGroupUnlocked) {
      // 공개된 조 번호
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ObangseokColors.cheong,
              Color(0xFF5DADE2),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ObangseokColors.cheong.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${pensionResult.groupNumber}조',
            style: TypographyUnified.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // 블러된 조 번호
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? ObangseokColors.meok.withValues(alpha: 0.5)
                : ObangseokColors.meok.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ObangseokColors.cheong.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Center(
                child: Text(
                  '${pensionResult.groupNumber}조',
                  style: TypographyUnified.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ObangseokColors.cheong,
                  ),
                ),
              ),
            ),
          ),
        ),
        // 자물쇠 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: ObangseokColors.cheong.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_rounded,
                color: ObangseokColors.cheong,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigit(int digit, bool isDark) {
    return Container(
      width: 36,
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? ObangseokColors.baekDark.withValues(alpha: 0.2)
              : ObangseokColors.meok.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: ObangseokColors.meok.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$digit',
          style: TypographyUnified.heading4.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? ObangseokColors.baekDark
                : ObangseokColors.meok,
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.cheong.withValues(alpha: 0.08)
            : ObangseokColors.cheong.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ObangseokColors.cheong.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: ObangseokColors.cheong,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pensionResult.fortuneMessage,
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark
                    ? ObangseokColors.baekDark.withValues(alpha: 0.8)
                    : ObangseokColors.meok.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 조 번호 잠금 해제 버튼
class _UnlockGroupButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UnlockGroupButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ObangseokColors.cheong,
              Color(0xFF5DADE2),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D3498DB),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '광고 보고 조 번호 확인',
              style: TypographyUnified.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
