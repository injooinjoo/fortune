import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortune/core/design_system/design_system.dart';

class MbtiCard extends StatelessWidget {
  final String mbti;
  final bool isSelected;
  final VoidCallback onTap;

  // MBTI 별칭 (상세정보)
  static const Map<String, String> mbtiNicknames = {
    'INTJ': '전략가',
    'INTP': '논리술사',
    'ENTJ': '통솔자',
    'ENTP': '변론가',
    'INFJ': '옹호자',
    'INFP': '중재자',
    'ENFJ': '선도자',
    'ENFP': '활동가',
    'ISTJ': '현실주의자',
    'ISFJ': '수호자',
    'ESTJ': '경영자',
    'ESFJ': '외교관',
    'ISTP': '장인',
    'ISFP': '모험가',
    'ESTP': '사업가',
    'ESFP': '연예인',
  };

  const MbtiCard({
    super.key,
    required this.mbti,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mbti,
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mbtiNicknames[mbti] ?? '',
                style: DSTypography.labelSmall.copyWith(
                  fontSize: 10, // 예외: 초소형 MBTI 별칭
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
