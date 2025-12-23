import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

/// 로또 행운의 조합 카드
class LottoLuckyComboCard extends StatelessWidget {
  final DateTime birthDate;

  const LottoLuckyComboCard({
    super.key,
    required this.birthDate,
  });

  List<int> _generateLuckyNumbers() {
    // 생일 기반 행운의 숫자 3개 생성
    final seed = birthDate.day + birthDate.month * 100 + birthDate.year;
    final random = Random(seed);
    final numbers = <int>{};

    while (numbers.length < 3) {
      numbers.add(random.nextInt(45) + 1);
    }

    return numbers.toList()..sort();
  }

  String _getElement() {
    final yearLastDigit = birthDate.year % 10;
    switch (yearLastDigit) {
      case 0:
      case 1:
        return '금(金)';
      case 2:
      case 3:
        return '수(水)';
      case 4:
      case 5:
        return '목(木)';
      case 6:
      case 7:
        return '화(火)';
      default:
        return '토(土)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final luckyNumbers = _generateLuckyNumbers();
    final element = _getElement();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '행운의 번호 조합',
                style: DSTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 오행 기반 설명
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    element,
                    style: DSTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '당신의 오행은 $element입니다. 이 기운과 맞는 번호를 추천합니다.',
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 행운의 숫자 3개
          Text(
            '행운의 숫자',
            style: DSTypography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: luckyNumbers.map((number) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: DSTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 12),

          // 팁
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: colors.textTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '이 숫자들을 조합에 포함시키면 당신의 오행 기운과 조화를 이룰 수 있습니다.',
                  style: DSTypography.bodySmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
