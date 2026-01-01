import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/font_config.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 로또 번호 카드 (5+1 구조, 여러 세트 지원)
///
/// 6개 번호 중 5개는 바로 공개, 1개는 광고 후 공개
/// gameCount > 1일 경우 여러 세트를 행별로 표시
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

            // 번호들 (여러 세트 지원)
            _buildNumbersSections(context, isDark),
            const SizedBox(height: 16),

            // 번호 색상 안내
            _buildColorGuide(isDark),
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
                  fontFamily: FontConfig.primary,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ObangseokColors.baekDark
                      : ObangseokColors.meok,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lottoResult.gameCount > 1
                    ? '사주 기반 맞춤 번호 ${lottoResult.gameCount}게임'
                    : '사주 기반 맞춤 번호 6개',
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

  /// 여러 세트 번호 표시 섹션
  Widget _buildNumbersSections(BuildContext context, bool isDark) {
    // 2개 이상 세트가 있으면 여러 세트 모드, 아니면 단일 세트 (하위 호환성)
    final hasSets = lottoResult.sets.length > 1;
    final setCount = hasSets ? lottoResult.sets.length : 1;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 너비에 따라 볼 크기 동적 계산
          final availableWidth = constraints.maxWidth - 16;
          final maxBallSize = (availableWidth - 40) / 6;
          // 여러 세트일 때는 볼 크기를 조금 줄임
          final ballSize = setCount > 1
              ? maxBallSize.clamp(32.0, 40.0)
              : maxBallSize.clamp(36.0, 48.0);

          if (hasSets) {
            // 여러 세트 표시
            return Column(
              children: [
                for (int i = 0; i < lottoResult.sets.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _buildSetRow(
                    setIndex: i,
                    set: lottoResult.sets[i],
                    isDark: isDark,
                    ballSize: ballSize,
                  ),
                ],
              ],
            );
          } else {
            // 단일 세트 (하위 호환성)
            return _buildSingleSetRow(isDark, ballSize);
          }
        },
      ),
    );
  }

  /// 단일 세트 행 (하위 호환성)
  Widget _buildSingleSetRow(bool isDark, double ballSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 5개 공개 번호
        ...lottoResult.visibleNumbers.map((number) => _buildNumberBall(
              number,
              isDark,
              isLocked: false,
              size: ballSize,
            )),
        // 1개 잠금 번호
        _buildNumberBall(
          lottoResult.lockedNumber,
          isDark,
          isLocked: !isPremiumUnlocked,
          size: ballSize,
        ),
      ],
    );
  }

  /// 세트별 번호 행
  Widget _buildSetRow({
    required int setIndex,
    required LottoNumberSet set,
    required bool isDark,
    required double ballSize,
  }) {
    return Row(
      children: [
        // 게임 번호 표시 (A, B, C, D, E)
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: ObangseokColors.hwang.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              String.fromCharCode(65 + setIndex), // A, B, C, D, E
              style: TypographyUnified.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: ObangseokColors.hwang,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 6개 번호
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 5개 공개 번호
              ...set.visibleNumbers.map((number) => _buildNumberBall(
                    number,
                    isDark,
                    isLocked: false,
                    size: ballSize,
                  )),
              // 1개 잠금 번호 (광고 전까지 블러)
              _buildNumberBall(
                set.lockedNumber,
                isDark,
                isLocked: !isPremiumUnlocked,
                size: ballSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberBall(int number, bool isDark, {required bool isLocked, double size = 48}) {
    final ballColor = Color(LottoNumberGenerator.getNumberColor(number));
    // 폰트 크기도 볼 크기에 비례하여 조정
    final fontSize = size * 0.38;

    final ball = Container(
      width: size,
      height: size,
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
          style: TypographyUnified.numberSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
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
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: ObangseokColors.hwang.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ObangseokColors.hwang,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: ObangseokColors.hwang,
                size: size * 0.42,
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
                style: TypographyUnified.labelTiny.copyWith(
                  color: isDark
                      ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                      : ObangseokColors.meok.withValues(alpha: 0.6),
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
