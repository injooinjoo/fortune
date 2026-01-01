import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 숫자 컨텐츠 - 행운의 숫자 표시
class NumberContent extends StatelessWidget {
  final List<int> numbers;
  final String? numbersExplanation;
  final List<int> avoidNumbers;

  const NumberContent({
    super.key,
    required this.numbers,
    this.numbersExplanation,
    this.avoidNumbers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 기본값 처리
    final displayNumbers = numbers.isNotEmpty ? numbers : [3, 7, 15, 22];
    final displayAvoid = avoidNumbers.isNotEmpty ? avoidNumbers : [4, 13];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          // 행운의 숫자 시각화
          Text(
            '오늘의 행운 숫자',
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 숫자 칩들
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: displayNumbers.map((n) {
              return _buildNumberChip(context, n, true, colors);
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 숫자 설명
          if (numbersExplanation != null && numbersExplanation!.isNotEmpty)
            InfoItem(label: '숫자 해석', value: numbersExplanation!)
          else
            const InfoItem(
              label: '숫자 해석',
              value: '오늘 이 숫자들이 행운을 가져다 줍니다. 로또, 비밀번호, 중요한 결정에 활용해보세요.',
            ),

          const SizedBox(height: 16),
          Divider(color: colors.border),
          const SizedBox(height: 16),

          // 피해야 할 숫자
          Text(
            '피해야 할 숫자',
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: displayAvoid.map((n) {
              return _buildNumberChip(context, n, false, colors);
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 활용 팁
          const InfoItem(
            label: '활용 팁',
            value: '행운 숫자를 조합하여 비밀번호나 중요한 번호에 활용해보세요',
          ),
        ],
      ),
    );
  }

  Widget _buildNumberChip(
    BuildContext context,
    int number,
    bool isLucky,
    DSColorScheme colors,
  ) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLucky ? colors.accent : colors.surfaceSecondary,
        border: Border.all(
          color: isLucky ? colors.accent : colors.error,
          width: 2,
        ),
        boxShadow: isLucky
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: DSTypography.headingSmall.copyWith(
            color: isLucky ? Colors.white : colors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
