import 'package:flutter/material.dart';
import 'info_item.dart';

/// 쇼핑/구매 컨텐츠
class ShoppingContent extends StatelessWidget {
  const ShoppingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            InfoItem(label: '행운 아이템', value: '블루 톤 액세서리'),
            InfoItem(label: '쇼핑 장소', value: '온라인 쇼핑몰'),
            InfoItem(label: '추천 브랜드', value: '자연 친화적 브랜드'),
            InfoItem(label: '구매 시간', value: '저녁 8시 이후'),
          ],
        ),
      ),
    );
  }
}
