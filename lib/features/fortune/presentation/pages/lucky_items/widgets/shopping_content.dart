import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 쇼핑/구매 컨텐츠 - API 데이터 사용
class ShoppingContent extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ShoppingContent({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터에서 추출 (없으면 기본값)
    final shoppingDetail = data?['shoppingDetail'] as Map<String, dynamic>?;
    final luckyItem = shoppingDetail?['luckyItem'] ?? '블루 톤 액세서리';
    final place = shoppingDetail?['place'] ?? '온라인 쇼핑몰';
    final brand = shoppingDetail?['brand'] ?? '자연 친화적 브랜드';
    final timing = shoppingDetail?['timing'] ?? '저녁 8시 이후';
    final tip = shoppingDetail?['tip'];

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
          InfoItem(label: '행운 아이템', value: luckyItem),
          InfoItem(label: '쇼핑 장소', value: place),
          InfoItem(label: '추천 브랜드', value: brand),
          InfoItem(label: '구매 시간', value: timing),
          if (tip != null) InfoItem(label: '팁', value: tip),
        ],
      ),
    );
  }
}
