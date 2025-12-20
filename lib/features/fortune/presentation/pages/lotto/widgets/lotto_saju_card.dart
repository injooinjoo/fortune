import 'package:flutter/material.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../domain/services/lotto_number_generator.dart';

/// 사주 기반 조언 카드
///
/// 오행 분석과 행운의 색상, 숫자대 등을 표시합니다.
class LottoSajuCard extends StatelessWidget {
  final SajuAdvice sajuAdvice;

  const LottoSajuCard({
    super.key,
    required this.sajuAdvice,
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

            // 오행 분석
            _buildElementAnalysis(isDark),
            const SizedBox(height: 16),

            // 재물운 점수
            _buildWealthScore(isDark),
            const SizedBox(height: 16),

            // 행운/비추천 번호대
            _buildNumberRanges(isDark),
            const SizedBox(height: 16),

            // 조언 메시지
            _buildAdviceMessage(isDark),
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
            color: ObangseokColors.hwang.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: ObangseokColors.hwang,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '사주 기반 조언',
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
                '오행 분석 결과',
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

  Widget _buildElementAnalysis(bool isDark) {
    final elementColor = _getElementColor(sajuAdvice.dominantElement);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor.withValues(alpha: 0.15),
            elementColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: elementColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // 오행 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: elementColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: elementColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getElementSymbol(sajuAdvice.dominantElement),
                style: TypographyUnified.heading3.copyWith(
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.w700,
                  color: elementColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sajuAdvice.dominantElement,
                      style: TypographyUnified.heading4.copyWith(
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        color: elementColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: elementColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sajuAdvice.luckyColor,
                        style: TypographyUnified.labelSmall.copyWith(
                          color: elementColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sajuAdvice.elementDescription,
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

  Widget _buildWealthScore(bool isDark) {
    final score = sajuAdvice.wealthScore;
    final scoreColor = score >= 80
        ? ObangseokColors.jeok
        : score >= 60
            ? ObangseokColors.hwang
            : ObangseokColors.cheong;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: scoreColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 재물운',
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                        : ObangseokColors.meok.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$score점',
                      style: TypographyUnified.heading4.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getScoreDescription(score),
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isDark
                            ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                            : ObangseokColors.meok.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 스코어 바
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: isDark
                    ? ObangseokColors.meok.withValues(alpha: 0.5)
                    : ObangseokColors.meok.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRanges(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberRangeItem(
            isDark,
            title: '행운의 번호대',
            value: sajuAdvice.luckyNumberRange,
            icon: Icons.star_rounded,
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberRangeItem(
            isDark,
            title: '피해야 할 번호대',
            value: sajuAdvice.avoidNumberRange,
            icon: Icons.block_rounded,
            isPositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberRangeItem(
    bool isDark, {
    required String title,
    required String value,
    required IconData icon,
    required bool isPositive,
  }) {
    final color = isPositive ? ObangseokColors.hwang : ObangseokColors.meok;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isPositive ? 0.3 : 0.15),
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
                color: isPositive
                    ? color
                    : (isDark
                        ? ObangseokColors.baekDark.withValues(alpha: 0.5)
                        : ObangseokColors.meok.withValues(alpha: 0.4)),
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
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ObangseokColors.baekDark
                  : ObangseokColors.meok,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.hwang.withValues(alpha: 0.08)
            : ObangseokColors.hwang.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ObangseokColors.hwang.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: ObangseokColors.hwang,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sajuAdvice.adviceMessage,
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

  Color _getElementColor(String element) {
    if (element.contains('목')) return ObangseokColors.cheong;
    if (element.contains('화')) return ObangseokColors.jeok;
    if (element.contains('토')) return ObangseokColors.hwang;
    if (element.contains('금')) return const Color(0xFFBDBDBD); // 백/금색
    if (element.contains('수')) return ObangseokColors.meok;
    return ObangseokColors.hwang;
  }

  String _getElementSymbol(String element) {
    if (element.contains('목')) return '木';
    if (element.contains('화')) return '火';
    if (element.contains('토')) return '土';
    if (element.contains('금')) return '金';
    if (element.contains('수')) return '水';
    return '?';
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '최상의 운세!';
    if (score >= 80) return '매우 좋음';
    if (score >= 70) return '좋음';
    if (score >= 60) return '보통';
    if (score >= 50) return '평범';
    return '조심';
  }
}
