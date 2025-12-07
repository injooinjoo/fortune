import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import 'info_item.dart';

/// 라이프스타일 컨텐츠 - ChatGPT 스타일
class LifestyleContent extends StatelessWidget {
  const LifestyleContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.gray900 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.gray800 : TossDesignSystem.gray200,
        ),
      ),
      child: const Column(
        children: [
          InfoItem(label: '취미 활동', value: '독서, 영화 감상'),
          InfoItem(label: '만남', value: '친구와 카페에서'),
          InfoItem(label: 'SNS 시간', value: '저녁 7시~9시'),
          InfoItem(label: '일상 팁', value: '새로운 시도를 해보세요'),
        ],
      ),
    );
  }
}
