import 'package:flutter/material.dart';
import 'info_item.dart';

/// 패션/뷰티 컨텐츠
class FashionContent extends StatelessWidget {
  const FashionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            InfoItem(label: '럭키 컬러', value: '네이비, 화이트'),
            InfoItem(label: '스타일링', value: '캐주얼 시크'),
            InfoItem(label: '액세서리', value: '실버 톤 귀걸이'),
            InfoItem(label: '뷰티', value: '자연스러운 메이크업'),
          ],
        ),
      ),
    );
  }
}
