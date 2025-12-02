import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import 'info_item.dart';

/// 패션/뷰티 컨텐츠 - ChatGPT 스타일
class FashionContent extends StatelessWidget {
  const FashionContent({super.key});

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
      child: const Column(
        children: [
          InfoItem(label: '럭키 컬러', value: '네이비, 화이트'),
          InfoItem(label: '스타일링', value: '캐주얼 시크'),
          InfoItem(label: '액세서리', value: '실버 톤 귀걸이'),
          InfoItem(label: '뷰티', value: '자연스러운 메이크업'),
        ],
      ),
    );
  }
}
