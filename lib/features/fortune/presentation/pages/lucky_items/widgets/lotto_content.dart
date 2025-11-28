import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import 'info_item.dart';

/// 로또/복권 컨텐츠
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 행운 번호',
              style: TypographyUnified.heading4.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers.asMap().entries.map((entry) {
                final index = entry.key;
                final number = entry.value;
                final isLastNumber = index == numbers.length - 1;

                // ✅ 마지막 번호만 블러 처리
                Widget numberWidget = Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TypographyUnified.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );

                // 마지막 번호이고 블러 상태면 블러 처리
                if (isLastNumber && isBlurred) {
                  numberWidget = Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: numberWidget,
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return numberWidget;
              }).toList(),
            ),
            const SizedBox(height: 24),
            const InfoItem(label: '구매 시간', value: '오후 2시~4시'),
            const InfoItem(label: '구매 장소', value: '집 근처 편의점'),
            const InfoItem(label: '행운 번호', value: '1, 7, 21번'),
          ],
        ),
      ),
    );
  }
}
