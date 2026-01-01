import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 음식/맛집 컨텐츠 - API 데이터 사용
class FoodContent extends StatelessWidget {
  final Map<String, dynamic>? foodDetail;

  const FoodContent({super.key, this.foodDetail});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터에서 추출 (없으면 기본값)
    final luckyMenu = foodDetail?['luckyMenu'] ?? '매콤한 국물 요리';
    final place = foodDetail?['place'] ?? '한식당, 분식집';
    final cafe = foodDetail?['cafe'] ?? '조용한 동네 카페';
    final mealTime = foodDetail?['mealTime'] ?? '점심 12시~1시';
    final tip = foodDetail?['tip'];

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
          InfoItem(label: '행운 메뉴', value: luckyMenu),
          InfoItem(label: '추천 장소', value: place),
          InfoItem(label: '카페', value: cafe),
          InfoItem(label: '식사 시간', value: mealTime),
          if (tip != null) InfoItem(label: '팁', value: tip),
        ],
      ),
    );
  }
}
