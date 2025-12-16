import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 쇼핑/구매 컨텐츠 - ChatGPT 스타일
class ShoppingContent extends StatelessWidget {
  const ShoppingContent({super.key});

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
          InfoItem(label: '행운 아이템', value: '블루 톤 액세서리'),
          InfoItem(label: '쇼핑 장소', value: '온라인 쇼핑몰'),
          InfoItem(label: '추천 브랜드', value: '자연 친화적 브랜드'),
          InfoItem(label: '구매 시간', value: '저녁 8시 이후'),
        ],
      ),
    );
  }
}
