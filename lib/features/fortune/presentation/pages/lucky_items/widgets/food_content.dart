import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 음식/맛집 컨텐츠 - ChatGPT 스타일
class FoodContent extends StatelessWidget {
  const FoodContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: const Column(
        children: [
          InfoItem(label: '행운 메뉴', value: '매콤한 국물 요리'),
          InfoItem(label: '추천 장소', value: '한식당, 분식집'),
          InfoItem(label: '카페', value: '조용한 동네 카페'),
          InfoItem(label: '식사 시간', value: '점심 12시~1시'),
        ],
      ),
    );
  }
}
