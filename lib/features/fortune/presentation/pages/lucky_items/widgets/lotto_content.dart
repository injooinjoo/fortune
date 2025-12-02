import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import 'info_item.dart';

/// 로또/복권 컨텐츠 - ChatGPT 스타일 미니멀 디자인
class LottoContent extends StatelessWidget {
  final List<int> numbers;
  final bool isBlurred;

  const LottoContent({
    super.key,
    required this.numbers,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Text(
            '오늘의 행운 번호',
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.gray300 : TossDesignSystem.gray700,
            ),
          ),
          const SizedBox(height: 16),

          // 번호 그리드 - 미니멀 스타일
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: numbers.asMap().entries.map((entry) {
              final index = entry.key;
              final number = entry.value;
              final isLastNumber = index == numbers.length - 1;

              Widget numberWidget = Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TypographyUnified.heading4.copyWith(
                      color: isDark ? TossDesignSystem.gray100 : TossDesignSystem.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );

              // 마지막 번호 블러 처리
              if (isLastNumber && isBlurred) {
                numberWidget = Stack(
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: numberWidget,
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: isDark ? TossDesignSystem.gray500 : TossDesignSystem.gray400,
                      ),
                    ),
                  ],
                );
              }

              return numberWidget;
            }).toList(),
          ),

          const SizedBox(height: 20),
          Divider(color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray200),
          const SizedBox(height: 16),

          // 추가 정보
          const InfoItem(label: '구매 시간', value: '오후 2시~4시'),
          const InfoItem(label: '구매 장소', value: '집 근처 편의점'),
          const InfoItem(label: '행운 번호', value: '1, 7, 21번'),
        ],
      ),
    );
  }
}
