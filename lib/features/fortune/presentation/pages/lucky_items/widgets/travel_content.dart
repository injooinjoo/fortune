import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import 'info_item.dart';

/// 여행/장소 컨텐츠 - ChatGPT 스타일
class TravelContent extends StatelessWidget {
  const TravelContent({super.key});

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
          InfoItem(label: '데이트 장소', value: '한강공원 산책로'),
          InfoItem(label: '드라이브', value: '북한산 둘레길'),
          InfoItem(label: '산책 장소', value: '남산 타워 주변'),
          InfoItem(label: '추천 시간', value: '오후 3시~6시'),
        ],
      ),
    );
  }
}
