import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import 'info_item.dart';

/// 게임/엔터 컨텐츠 - ChatGPT 스타일
class GameContent extends StatelessWidget {
  const GameContent({super.key});

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
          InfoItem(label: '추천 게임', value: 'RPG, 전략 게임'),
          InfoItem(label: '추천 콘텐츠', value: '여행 다큐멘터리'),
          InfoItem(label: '음악', value: '재즈, 클래식'),
          InfoItem(label: '행운 시간', value: '밤 10시 이후'),
        ],
      ),
    );
  }
}
